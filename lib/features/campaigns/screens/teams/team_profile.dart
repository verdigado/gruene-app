import 'package:flutter/material.dart';
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
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
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
                  (currentTeam.division?.shortDisplayName()).safe(),
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
      builder: (context) => newTeamWidget,
      isScrollControlled: false,
      isDismissible: true,
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
          builder: (context) => editTeamMembersWidget,
          isScrollControlled: false,
          isDismissible: false,
          enableDrag: false,
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
