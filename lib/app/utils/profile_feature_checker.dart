// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/features/profiles/widgets/profile_visibility_setting.dart';
import 'package:http/http.dart';
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
      try {
        var profileService = GetIt.I<GrueneApiProfileService>();
        var currentProfile = await profileService.getSelf();
        if (!currentProfile.isVisibleInKV()) {
          if (!context.mounted) return;
          showProfileVisibilitySetting(context, currentProfile, explicitTeamHint: true);

          latestProfileCheckSettings = latestProfileCheckSettings?.copyWith(hasProfilePrivacyCheckCompleted: true);
          secureStorage.write(key: SecureStorageKeys.profileCheck, value: latestProfileCheckSettings?.toJson());
        }
      } on ClientException {
        // Don't crash the app on network errors
      }
    }
  }

  Future<String?> _getCurrentUserId(String? currentAccessToken) async {
    var jwtToken = JwtDecoder.decode(currentAccessToken!);
    String? userId;
    if (jwtToken.containsKey('uidnumber')) userId = jwtToken['uidnumber'].toString();
    return userId;
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
