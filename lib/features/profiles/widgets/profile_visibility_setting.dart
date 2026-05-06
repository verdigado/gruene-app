import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/widgets/option_slider.dart';
import 'package:gruene_app/app/widgets/stable_height_text.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/profiles/utils/profile_visibility.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileVisibilitySetting extends StatefulWidget {
  final Profile profile;
  final bool explicitTeamHint;

  const ProfileVisibilitySetting({super.key, required this.profile, this.explicitTeamHint = false});

  @override
  State<ProfileVisibilitySetting> createState() => _ProfileVisibilitySettingState();
}

class _ProfileVisibilitySettingState extends State<ProfileVisibilitySetting> {
  late ProfilePrivacySettingsOverall _selectedVisibility;

  @override
  void initState() {
    super.initState();
    _selectedVisibility = widget.profile.privacy.overall;
  }

  Future<void> _updateProfile() async {
    if (widget.profile.privacy.overall == _selectedVisibility) {
      Navigator.pop(context);
      return;
    }

    final profileService = GetIt.I<GrueneApiProfileService>();
    final newProfile = widget.profile.copyWith(privacy: widget.profile.privacy.copyWith(overall: _selectedVisibility));

    await tryAndNotify(
      function: () => profileService.updateProfile(newProfile),
      context: context,
      successMessage: t.profiles.visibility.updated,
    );
    if (!mounted) return;
    Navigator.pop(context, newProfile);
  }

  @override
  Widget build(BuildContext context) {
    final memberships = widget.profile.memberships!;
    // TODO: Adjust to OV if teams are available for OVs and user is in an OV
    // final minVisibility = memberships.profileVisibilityOptions()[2];
    final minVisibility = ProfilePrivacySettingsOverall.kvWide;
    final minVisibilityLabel = visibilityLabel(minVisibility);
    final minVisibilityShort = visibilityShortLabel(minVisibility);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        CloseSaveWidget(onClose: () => Navigator.pop(context), onSave: _updateProfile),
        Row(
          spacing: 8,
          children: [
            Icon(Icons.visibility),
            Text(t.profiles.visibility.visibility, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        if (widget.explicitTeamHint) ...[
          Text(
            t.profiles.visibility.teamVisibilityHint(
              minVisibility: minVisibilityLabel,
              minVisibilityShort: minVisibilityShort,
            ),
          ),
          SizedBox(height: 8),
        ],
        Text(
          visibilityLabel(_selectedVisibility),
          style: theme.textTheme.titleSmall?.apply(color: ThemeColors.textDark),
        ),
        StableHeightText(
          text: visibilityHint(_selectedVisibility),
          longestText: visibilityHint(ProfilePrivacySettingsOverall.private),
          style: theme.textTheme.bodyMedium!,
        ),
        OptionSlider(
          values: memberships.profileVisibilityOptions(),
          value: _selectedVisibility,
          getLabel: (value) => visibilityShortLabel(value),
          update: (visibility) => setState(() => _selectedVisibility = visibility),
        ),
      ],
    );
  }
}

Future<Profile?> showProfileVisibilitySetting(
  BuildContext context,
  Profile profile, {
  bool explicitTeamHint = false,
}) async {
  if (profile.memberships == null) return null;

  return await showModalBottomSheet<Profile>(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: defaultScreenPadding.copyWith(bottom: 48),
            child: ProfileVisibilitySetting(profile: profile, explicitTeamHint: explicitTeamHint),
          ),
        ),
      );
    },
  );
}
