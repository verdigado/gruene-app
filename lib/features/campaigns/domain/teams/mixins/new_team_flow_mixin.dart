part of '../mixins.dart';

/// Mixin for handling the new team creation flow.
/// Responsible for UI navigation and user interaction only.
/// Business logic is delegated to [TeamCreationService].
mixin NewTeamFlowMixin {
  /// Callback to reload data after team creation
  void reload();

  /// Provides current user information
  UserRbacStructure getCurrentUserInfo();

  /// Returns a button that triggers the new team creation flow
  GestureDetector getNewTeamButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _beginCreateNewTeam(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(t.campaigns.team.create_team, style: theme.textTheme.bodyLarge),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
            ),
          ],
        ),
      ),
    );
  }

  /// Starts the team creation flow
  Future<void> _beginCreateNewTeam(BuildContext context) async {
    final newTeamWidget = const NewTeamBasicInfoWidget();
    final newDetails = await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);

    if (!context.mounted) return;
    if (newDetails == null) return;

    await _handleTeamCreationFlow(context, newDetails);
  }

  /// Handles the complete team creation flow with all steps
  Future<void> _handleTeamCreationFlow(BuildContext context, NewTeamDetails initialDetails) async {
    final teamService = GetIt.I<GrueneApiTeamsService>();
    final creationService = TeamCreationService(teamService);
    final currentUser = getCurrentUserInfo();

    // Check if user is joining the new team and is already in a team
    final isCreatingUserInNewTeam = creationService.isCreatingUserInNewTeam(initialDetails, currentUser);
    final currentTeamOfCreatingUser = isCreatingUserInNewTeam ? await teamService.getOwnTeam() : null;

    if (isCreatingUserInNewTeam && currentTeamOfCreatingUser != null) {
      if (!context.mounted) return;
      final shouldContinue = await TeamHelper.getConfirmationJoiningNewTeam(
        context: context,
        currentTeamName: currentTeamOfCreatingUser.name,
        newTeamName: initialDetails.name,
        askForConfirmation: false,
      );
      if (!shouldContinue) return;
    }

    if (!context.mounted) return;

    // Step 1: Division selection
    final divisionDetails = await _showStepDivisionSelect(initialDetails, context);
    if (divisionDetails == null) return;

    if (!context.mounted) return;

    // Step 2: Team lead selection
    final teamLeadDetails = await _showStepTeamLeadSelect(divisionDetails, context);
    if (teamLeadDetails == null) return;

    if (!context.mounted) return;

    // Step 3: Team member selection and final creation
    await _showStepTeamMemberSelect(teamLeadDetails, context);
  }

  /// Shows the division selection step
  Future<NewTeamDetails?> _showStepDivisionSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    final newTeamWidget = NewTeamSelectDivisionWidget(
      newTeamDetails: newTeamDetails,
      currentUserInfo: getCurrentUserInfo(),
    );
    return await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);
  }

  /// Shows the team lead selection step (skipped if self-join)
  Future<NewTeamDetails?> _showStepTeamLeadSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    NewTeamDetails? newDetails = newTeamDetails;
    if (!newDetails.selfJoin) {
      final newTeamWidget = NewTeamSelectTeamLeadWidget(newTeamDetails: newTeamDetails);
      newDetails = await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);
    }
    return newDetails;
  }

  /// Shows the team member selection step and handles final creation
  Future<void> _showStepTeamMemberSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    var canceledOrSaved = false;
    NewTeamDetails? newDetails = newTeamDetails;

    final teamService = GetIt.I<GrueneApiTeamsService>();
    final creationService = TeamCreationService(teamService);
    final currentUser = getCurrentUserInfo();

    while (!canceledOrSaved) {
      final newTeamWidget = NewTeamSelectTeamMemberWidget(newTeamDetails: newDetails!);
      if (!context.mounted) return;
      newDetails = await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);

      if (newDetails != null) {
        final isCreatingUserInNewTeam = creationService.isCreatingUserInNewTeam(newDetails, currentUser);

        try {
          await creationService.createTeam(newDetails);
          if (isCreatingUserInNewTeam) reload();
          canceledOrSaved = true;
        } on ApiException {
          if (context.mounted) showToastAsSnack(context, t.error.unknownError);
        }
      } else {
        canceledOrSaved = true;
      }
    }
  }

  /// Shows a modal bottom sheet with the given child widget
  Future<U?> _showModalBottomSheet<U>(Widget child, BuildContext context) async {
    final theme = Theme.of(context);
    return await showModalBottomSheet<U>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding)),
        child: child,
      ),
      isScrollControlled: true,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
