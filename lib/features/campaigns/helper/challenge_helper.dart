import 'package:flutter/material.dart' hide Visibility;
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_challenge_service.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ChallengeHelper {
  static Future<ChallengeMembership?> joinChallenge(BuildContext context, Challenge challenge) async {
    Profile? profile;
    try {
      var profileService = GetIt.I<GrueneApiProfileService>();
      profile = await profileService.getSelf();
    } catch (e) {
      profile = null;
    }
    var appSettings = GetIt.I<AppSettings>();

    if (!appSettings.challengePrivacyDialogSeen && (profile == null || profile.privacy.overall != Visibility.public)) {
      appSettings.challengePrivacyDialogSeen = true;
      if (!context.mounted) return null;
      var confirmResult =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(t.campaigns.challenges.joinConfirmationDialog.dialogTitle),
              content: Text(t.campaigns.challenges.joinConfirmationDialog.dialogText),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(t.common.actions.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(t.campaigns.challenges.joinConfirmationDialog.dialogAccept),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmResult) return null;
    }

    var challengeService = GetIt.I<GrueneApiChallengeService>();
    var joinResult = await challengeService.joinChallenge(challenge.id);
    if (!context.mounted) return null;
    showToastAsSnack(context, t.campaigns.challenges.joinConfirmationDialog.joinToast(title: challenge.title));
    return joinResult;
  }

  static Future<void> leaveChallenge(BuildContext context, Challenge challenge) async {
    if (!context.mounted) return null;
    var confirmResult =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(t.campaigns.challenges.leaveConfirmationDialog.dialogText),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(t.common.actions.cancel)),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(t.common.actions.confirm)),
            ],
          ),
        ) ??
        false;
    if (!confirmResult) return;

    var challengeService = GetIt.I<GrueneApiChallengeService>();
    await challengeService.leaveChallenge(challenge.id);
    if (!context.mounted) return;
    showToastAsSnack(context, t.campaigns.challenges.leaveConfirmationDialog.leaveToast(title: challenge.title));
  }
}
