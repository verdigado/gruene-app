import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/screens/profile/profile_visibility_setting.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileVisibilityHint extends StatelessWidget {
  final Profile? currentProfile;
  final void Function(Profile? preloadedProfile) reloadProfile;

  const ProfileVisibilityHint({super.key, this.currentProfile, required this.reloadProfile});

  @override
  Widget build(BuildContext context) {
    if (currentProfile == null) {
      return SizedBox.shrink();
    } else if (!currentProfile!.isVisibleInKV()) {
      var theme = Theme.of(context);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: boxShadowDecoration,
          child: Column(
            children: [
              Row(children: [Expanded(child: Text(t.campaigns.team.profile_visibility_hint, softWrap: true))]),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showProfileVisibilitySettings(context),
                    child: Text(
                      t.profile.visibility_setting.visibility_setting_action,
                      style: theme.textTheme.labelMedium?.apply(
                        decoration: TextDecoration.underline,
                        color: ThemeColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Future<void> _showProfileVisibilitySettings(BuildContext context) async {
    if (currentProfile == null) throw ArgumentError('Profile not set');

    var theme = Theme.of(context);
    var newTeamWidget = ProfileVisibilitySetting(currentProfile: currentProfile!);
    var newProfile = await showModalBottomSheet<Profile>(
      context: context,
      builder: (context) => newTeamWidget,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: theme.colorScheme.surface,
    );
    if (newProfile != null) {
      reloadProfile(newProfile);
    }
  }
}
