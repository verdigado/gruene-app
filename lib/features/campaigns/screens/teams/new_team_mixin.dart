import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
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
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

mixin NewTeamMixin {
  void reload();
  UserRbacStructure getCurrentUserInfo();

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
    var newTeamWidget = NewTeamBasicInfoWidget();
    var newDetails = await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);

    if (context.mounted) {
      if (newDetails != null) {
        _showStepDivisionSelect(newDetails, context);
      }
    }
  }

  void _showStepDivisionSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    var newTeamWidget = NewTeamSelectDivisionWidget(
      newTeamDetails: newTeamDetails,
      currentUserInfo: getCurrentUserInfo(),
    );
    var newDetails = await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);

    if (context.mounted) {
      if (newDetails != null) {
        _showStepTeamLeadSelect(newDetails, context);
      }
    }
  }

  void _showStepTeamLeadSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    NewTeamDetails? newDetails = newTeamDetails;
    if (!newDetails.selfJoin) {
      var newTeamWidget = NewTeamSelectTeamLeadWidget(newTeamDetails: newTeamDetails);
      newDetails = await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);
    }

    if (context.mounted) {
      if (newDetails != null) {
        _showStepTeamMemberSelect(newDetails, context);
      }
    }
  }

  Future<void> _showStepTeamMemberSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    var canceledOrSaved = false;
    NewTeamDetails? newDetails = newTeamDetails;
    while (!canceledOrSaved) {
      var newTeamWidget = NewTeamSelectTeamMemberWidget(newTeamDetails: newDetails!);
      if (!context.mounted) return;
      newDetails = await _showModalBottomSheet<NewTeamDetails>(newTeamWidget, context);

      if (newDetails != null) {
        var teamService = GetIt.I<GrueneApiTeamsService>();

        var isCreatingUserInNewTeam = newDetails.getAllMemberships().any(
          (m) => m.userId == newDetails?.creatingUser.userId,
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
          if (context.mounted) showToastAsSnack(context, t.error.unknownError);
        }
      } else {
        canceledOrSaved = true;
      }
    }
  }

  Future<U?> _showModalBottomSheet<U>(Widget child, BuildContext context) async {
    var theme = Theme.of(context);
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
