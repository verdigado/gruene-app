import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
import 'package:gruene_app/app/widgets/option_slider.dart';
import 'package:gruene_app/app/widgets/stable_height_text.dart';
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

    final teamsService = GetIt.I<GrueneApiTeamsService>();
    final profileService = GetIt.I<GrueneApiProfileService>();
    final newProfile = widget.profile.copyWith(privacy: widget.profile.privacy.copyWith(overall: _selectedVisibility));

    final team = await tryAndNotify(
      function: () async {
        await profileService.updateProfile(newProfile);
        return await teamsService.getOwnTeam();
      },
      context: context,
      successMessage: t.profiles.visibility.updated,
    );

    if (!mounted) return;
    Navigator.pop(context, newProfile);

    if (_selectedVisibility == ProfilePrivacySettingsOverall.private && team != null) {
      await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.profiles.visibility.privateProfileInTeamTitle),
          content: Text(t.profiles.visibility.privateProfileInTeamHint(team: team.name)),
          actions: [TextButton(onPressed: Navigator.of(context).pop, child: Text(t.common.actions.confirm))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVisibilityOptions = widget.profile.memberships!.profileVisibilityOptions();
    // TODO: Adjust to OV if teams are available for OVs and user is in an OV
    // final minVisibility = memberships.profileVisibilityOptions()[2];
    final minVisibility = ProfilePrivacySettingsOverall.kvWide;
    final minVisibilityLabel = visibilityLabel(minVisibility);
    final minVisibilityShort = visibilityShortLabel(minVisibility);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _updateProfile();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: defaultScreenPadding.left, right: 8),
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.visibility),
                Text(t.profiles.visibility.visibility, style: Theme.of(context).textTheme.titleMedium),
                Spacer(),
                DialogCloseButton(onClose: _updateProfile),
              ],
            ),
          ),
          Padding(
            padding: defaultScreenPadding.copyWith(top: 0, bottom: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
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
                  values: profileVisibilityOptions,
                  value: _selectedVisibility,
                  getLabel: (value) => visibilityShortLabel(value),
                  update: (visibility) => setState(() => _selectedVisibility = visibility),
                ),
              ],
            ),
          ),
        ],
      ),
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
    builder: (context) => ProfileVisibilitySetting(profile: profile, explicitTeamHint: explicitTeamHint),
  );
}
