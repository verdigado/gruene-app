import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/campaigns/screens/teams/edit_team_basic_info_widget.dart';
import 'package:gruene_app/features/campaigns/screens/teams/edit_team_members_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamProfile extends StatelessWidget {
  final Team currentTeam;
  final UserRbacStructure currentUser;
  final void Function(Team? preloadedTeam) reloadTeam;

  const TeamProfile({super.key, required this.currentTeam, required this.currentUser, required this.reloadTeam});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: boxShadowDecoration,
        child: Column(
          children: [
            currentTeam.isTeamLead(currentUser)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _onEditTeam(context),
                        child: Text(
                          t.common.actions.edit,
                          style: theme.textTheme.labelMedium?.apply(
                            color: ThemeColors.textDark,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            Row(
              children: [Expanded(child: Text(currentTeam.name, style: theme.textTheme.displayLarge, softWrap: true))],
            ),
            Row(
              children: [
                Text(
                  (currentTeam.division?.shortName).safe(),
                  style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled),
                ),
              ],
            ),
            Row(
              children: [
                currentTeam.description != null
                    ? Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text.rich(
                            currentTeam.description.safe().asRichText(context),
                            style: theme.textTheme.bodyMedium,
                            softWrap: true,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            currentTeam.isTeamLead(currentUser)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _onEditTeamMembers(context),
                        child: Text(
                          t.campaigns.team.edit_team_members,
                          style: theme.textTheme.labelMedium?.apply(
                            color: ThemeColors.textDark,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> _onEditTeam(BuildContext context) async {
    final theme = Theme.of(context);

    var newTeamWidget = EditTeamBasicInfoWidget(team: currentTeam);
    var result = await showModalBottomSheet<Team>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsetsGeometry.only(
          bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding),
        ),
        child: newTeamWidget,
      ),
      isScrollControlled: true,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
    );

    if (context.mounted) {
      if (result != null) {
        reloadTeam(result);
      }
    }
  }

  Future<void> _onEditTeamMembers(BuildContext context) async {
    final theme = Theme.of(context);

    var editTeamMembersWidget = EditTeamMembersWidget(team: currentTeam, currentUser: currentUser);
    var result =
        await showModalBottomSheet<bool>(
          context: context,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding),
            ),
            child: editTeamMembersWidget,
          ),
          isScrollControlled: true,
          isDismissible: true,
          useRootNavigator: true,
          backgroundColor: theme.colorScheme.surface,
        ) ??
        false;

    if (context.mounted) {
      if (result) {
        reloadTeam(null);
      }
    }
  }
}
