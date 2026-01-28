// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/features/campaigns/screens/profile/profile_visibility_setting.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileFeatureChecker {
  ProfileCheckSettings? latestProfileCheckSettings;

  Future<void> _loadProfileCheckSettings(
    FlutterSecureStorage secureStorage,
    ProfileCheckSettings defaultProfileCheckSetting,
  ) async {
    var profileCheckSerialized = await secureStorage.read(key: SecureStorageKeys.profileCheck);

    try {
      latestProfileCheckSettings = profileCheckSerialized != null
          ? ProfileCheckSettings.fromJson(profileCheckSerialized)
          : defaultProfileCheckSetting;

      if (latestProfileCheckSettings!.userId != defaultProfileCheckSetting.userId) {
        latestProfileCheckSettings = defaultProfileCheckSetting;
      }
    } on Exception {
      latestProfileCheckSettings = defaultProfileCheckSetting;
    }
  }

  void check(BuildContext context) async {
    final FlutterSecureStorage secureStorage = GetIt.instance<FlutterSecureStorage>();
    var currentUserId = await _getCurrentUserId(await secureStorage.read(key: SecureStorageKeys.accessToken));
    if (latestProfileCheckSettings == null) {
      await _loadProfileCheckSettings(secureStorage, ProfileCheckSettings(userId: currentUserId!));
    }

    if (!latestProfileCheckSettings!.hasProfilePrivacyCheckCompleted) {
      var profileService = GetIt.I<GrueneApiProfileService>();
      var currentProfile = await profileService.getSelf();
      if (!currentProfile.isVisibleInKV()) {
        if (!context.mounted) return;
        _showProfileSettingDialog(context, currentProfile);

        latestProfileCheckSettings = latestProfileCheckSettings?.copyWith(hasProfilePrivacyCheckCompleted: true);
        secureStorage.write(key: SecureStorageKeys.profileCheck, value: latestProfileCheckSettings?.toJson());
      }
    }
  }

  Future<String?> _getCurrentUserId(String? currentAccessToken) async {
    var jwtToken = JwtDecoder.decode(currentAccessToken!);
    String? userId;
    if (jwtToken.containsKey('uidnumber')) userId = jwtToken['uidnumber'].toString();
    return userId;
  }

  void _showProfileSettingDialog(BuildContext context, Profile currentProfile) async {
    final theme = Theme.of(context);
    await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            t.campaigns.team.profile_visibility_hint,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(fontSizeDelta: 1),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showProfileVisibilitySettings(context, currentProfile);
              },
              child: Text(
                t.common.actions.consent,
                style: theme.textTheme.labelLarge?.apply(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProfileVisibilitySettings(BuildContext context, Profile currentProfile) async {
    var theme = Theme.of(context);
    var newTeamWidget = ProfileVisibilitySetting(currentProfile: currentProfile);
    await showModalBottomSheet<Profile>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: DesignConstants.bottomPadding),
        child: newTeamWidget,
      ),
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: theme.colorScheme.surface,
      useRootNavigator: true,
    );
  }
}

class ProfileCheckSettings {
  final String userId;

  final bool hasProfilePrivacyCheckCompleted;

  ProfileCheckSettings({required this.userId, this.hasProfilePrivacyCheckCompleted = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'userId': userId, 'hasProfileCheckCompleted': hasProfilePrivacyCheckCompleted};
  }

  factory ProfileCheckSettings.fromMap(Map<String, dynamic> map) {
    return ProfileCheckSettings(
      userId: map['userId'] as String,
      hasProfilePrivacyCheckCompleted: map['hasProfileCheckCompleted'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileCheckSettings.fromJson(String source) =>
      ProfileCheckSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  ProfileCheckSettings copyWith({String? userId, bool? hasProfilePrivacyCheckCompleted}) {
    return ProfileCheckSettings(
      userId: userId ?? this.userId,
      hasProfilePrivacyCheckCompleted: hasProfilePrivacyCheckCompleted ?? this.hasProfilePrivacyCheckCompleted,
    );
  }
}
