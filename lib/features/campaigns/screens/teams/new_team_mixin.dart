import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/campaigns/helper/team_helper.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_basic_info_widget.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_select_division_widget.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_select_team_lead_widget.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_select_team_member_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';

mixin NewTeamMixin {
  void reload();

  GestureDetector getNewTeamButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _beginCreateNewTeam(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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

  void _beginCreateNewTeam(BuildContext context) async {
    final theme = Theme.of(context);

    var newTeamWidget = NewTeamBasicInfoWidget();
    var newDetails = await showModalBottomSheet<NewTeamDetails>(
      context: context,
      builder: (context) => newTeamWidget,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: theme.colorScheme.surface,
    );

    if (context.mounted) {
      if (newDetails != null) {
        _showStepDivisionSelect(newDetails, context);
      }
    }
  }

  void _showStepDivisionSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    final theme = Theme.of(context);

    var newTeamWidget = NewTeamSelectDivisionWidget(newTeamDetails: newTeamDetails);
    var newDetails = await showModalBottomSheet<NewTeamDetails>(
      context: context,
      builder: (context) => newTeamWidget,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: theme.colorScheme.surface,
    );

    if (context.mounted) {
      if (newDetails != null) {
        _showStepTeamLeadSelect(newDetails, context);
      }
    }
  }

  void _showStepTeamLeadSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    final theme = Theme.of(context);
    NewTeamDetails? newDetails = newTeamDetails;
    if (!newDetails.selfJoin) {
      var newTeamWidget = NewTeamSelectTeamLeadWidget(newTeamDetails: newTeamDetails);
      newDetails = await showModalBottomSheet<NewTeamDetails>(
        context: context,
        builder: (context) => newTeamWidget,
        isScrollControlled: false,
        isDismissible: true,
        backgroundColor: theme.colorScheme.surface,
      );
    }

    if (context.mounted) {
      if (newDetails != null) {
        _showStepTeamMemberSelect(newDetails, context);
      }
    }
  }

  Future<void> _showStepTeamMemberSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    final theme = Theme.of(context);
    var canceledOrSaved = false;
    while (!canceledOrSaved) {
      var newTeamWidget = NewTeamSelectTeamMemberWidget(newTeamDetails: newTeamDetails);
      if (!context.mounted) return;
      var newDetails = await showModalBottomSheet<NewTeamDetails>(
        context: context,
        builder: (context) => newTeamWidget,
        isScrollControlled: false,
        isDismissible: true,
        backgroundColor: theme.colorScheme.surface,
      );

      if (newDetails != null) {
        var teamService = GetIt.I<GrueneApiTeamsService>();

        var isCreatingUserInNewTeam = newDetails.getAllMemberships().any(
          (m) => m.userId == newDetails.creatingUser.userId,
        );
        var currentTeamOfCreatingUser = await GetIt.I<GrueneApiTeamsService>().getOwnTeam();

        // check whether current user is joining the new team and is already in a team
        if (isCreatingUserInNewTeam && currentTeamOfCreatingUser != null) {
          if (!context.mounted) return;
          var confirmed = await TeamHelper.getConfirmationJoiningNewTeam(
            context: context,
            currentTeamName: currentTeamOfCreatingUser.name,
            newTeamName: newDetails.name,
          );
          if (!confirmed) return;
        }

        try {
          await teamService.createNewTeam(newDetails);
          if (isCreatingUserInNewTeam) reload();
          canceledOrSaved = true;
        } on ApiException {
          if (context.mounted) showSnackBar(context, t.error.unknownError);
          newTeamDetails = newDetails;
        }
      } else {
        canceledOrSaved = true;
      }
    }
  }
}
