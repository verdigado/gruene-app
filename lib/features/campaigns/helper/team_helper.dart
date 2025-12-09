import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class TeamHelper {
  static Future<bool> getConfirmationJoiningNewTeam({
    required BuildContext context,
    required String currentTeamName,
    required String newTeamName,
  }) async {
    var theme = Theme.of(context);
    var dialogResult = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.alertBackground,
          content: Text(
            t.campaigns.team.invitations.warning_user_already_in_team(
              current_team: currentTeamName,
              inviting_team: newTeamName,
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(color: theme.colorScheme.surface, fontSizeDelta: 1),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                t.common.actions.cancel,
                style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textWarning),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                t.common.actions.consent,
                style: theme.textTheme.labelLarge?.apply(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        );
      },
    );
    return dialogResult ?? false;
  }
}
