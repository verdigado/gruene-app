import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/profiles/utils/profile_visibility.dart';
import 'package:gruene_app/features/profiles/widgets/profile_visibility_setting.dart';
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
      // TODO: Adjust to OV if teams are available for OVs and user is in an OV
      // final minVisibility = memberships.profileVisibilityOptions()[2];
      final minVisibility = ProfilePrivacySettingsOverall.kvWide;
      final minVisibilityLabel = visibilityLabel(minVisibility);
      final minVisibilityShort = visibilityShortLabel(minVisibility);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: boxShadowDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.profiles.visibility.teamVisibilityHint(
                        minVisibility: minVisibilityLabel,
                        minVisibilityShort: minVisibilityShort,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showProfileVisibilitySettings(context),
                    child: Text(
                      t.profiles.visibility.visibility,
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

    var newProfile = await showProfileVisibilitySetting(context, currentProfile!);
    if (newProfile != null) {
      reloadProfile(newProfile);
    }
  }
}
