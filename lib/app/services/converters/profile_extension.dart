part of '../converters.dart';

extension ProfileExtension on Profile {
  bool isVisibleInKV() {
    switch (privacy.overall) {
      case ProfilePrivacySettingsOverall.private:
      case ProfilePrivacySettingsOverall.ovWide:
        return false;
      case ProfilePrivacySettingsOverall.kvWide:
      case ProfilePrivacySettingsOverall.public:
      case ProfilePrivacySettingsOverall.lvWide:
      case ProfilePrivacySettingsOverall.bvWide:
        return true;
      case ProfilePrivacySettingsOverall.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
