import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileVisibilitySetting extends StatefulWidget {
  final Profile currentProfile;
  const ProfileVisibilitySetting({super.key, required this.currentProfile});

  @override
  State<ProfileVisibilitySetting> createState() => _ProfileVisibilitySettingState();
}

class _ProfileVisibilitySettingState extends State<ProfileVisibilitySetting> {
  late ProfilePrivacySettingsOverall _currentPrivacySetting;

  @override
  void initState() {
    _currentPrivacySetting = widget.currentProfile.privacy.overall;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      height: 422,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CloseSaveWidget(onClose: _onClose, onSave: _onSave),
            SizedBox(height: 8),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.profile.visibility_setting.title, style: theme.textTheme.titleMedium),
                ),
                SizedBox(height: 16),

                ..._getVisibilityOptions(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onClose() {
    Navigator.pop(context);
  }

  Future<void> _onSave() async {
    var profileService = GetIt.I<GrueneApiProfileService>();
    var newProfile = await profileService.updateProfile(
      widget.currentProfile.copyWith(privacy: widget.currentProfile.privacy.copyWith(overall: _currentPrivacySetting)),
    );
    if (!mounted) return;
    Navigator.pop(context, newProfile);
  }

  List<Widget> _getVisibilityOptions() {
    return [
      _getSingleVisibilityOption(
        value: ProfilePrivacySettingsOverall.public,
        title: t.profile.visibility_setting.visibility_public,
      ),
      _getSingleVisibilityOption(
        value: ProfilePrivacySettingsOverall.bvWide,
        title: t.profile.visibility_setting.visibility_BV,
      ),
      _getSingleVisibilityOption(
        value: ProfilePrivacySettingsOverall.lvWide,
        title: t.profile.visibility_setting.visibility_LV,
      ),
      _getSingleVisibilityOption(
        value: ProfilePrivacySettingsOverall.kvWide,
        title: t.profile.visibility_setting.visibility_KV,
      ),
      _getSingleVisibilityOption(
        value: ProfilePrivacySettingsOverall.ovWide,
        title: t.profile.visibility_setting.visibility_OV,
      ),
      _getSingleVisibilityOption(
        value: ProfilePrivacySettingsOverall.private,
        title: t.profile.visibility_setting.visibility_private,
      ),
    ];
  }

  Widget _getSingleVisibilityOption({required ProfilePrivacySettingsOverall value, required String title}) {
    var theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textDark)),
        Switch(
          value: _currentPrivacySetting == value,
          onChanged: (flag) {
            var newValue = flag ? value : ProfilePrivacySettingsOverall.private;
            setState(() {
              _currentPrivacySetting = newValue;
            });
          },
        ),
      ],
    );
  }
}
