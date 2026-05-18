import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/profile.dart';
import 'package:gruene_app/features/profiles/utils/profile_visibility.dart';
import 'package:gruene_app/features/profiles/widgets/profile_visibility_setting.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileVisibilityHint extends StatelessWidget {
  final Profile? currentProfile;
  final void Function(Profile? preloadedProfile) reloadProfile;

  const ProfileVisibilityHint({super.key, required this.currentProfile, required this.reloadProfile});

  @override
  Widget build(BuildContext context) {
    final profile = currentProfile;
    if (profile == null || profile.isVisibleInKV()) return SizedBox.shrink();

    final theme = Theme.of(context);
    final minVisibility = profile.minTeamVisibilityOption();
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
                  onTap: () async {
                    final newProfile = await showProfileVisibilitySetting(context, profile);
                    if (newProfile != null) {
                      reloadProfile(newProfile);
                    }
                  },
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
  }
}
