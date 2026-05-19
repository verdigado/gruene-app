import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

String visibilityLabel(ProfilePrivacySettingsOverall visibility) => switch (visibility) {
  ProfilePrivacySettingsOverall.private => t.profiles.visibility.private,
  ProfilePrivacySettingsOverall.ovWide => t.divisions.level.ov.label,
  ProfilePrivacySettingsOverall.kvWide => t.divisions.level.kv.label,
  ProfilePrivacySettingsOverall.lvWide => t.divisions.level.lv.label,
  ProfilePrivacySettingsOverall.bvWide => t.divisions.level.bv.label,
  ProfilePrivacySettingsOverall.public => t.profiles.visibility.public,
  _ => '',
};

String visibilityShortLabel(ProfilePrivacySettingsOverall visibility) => switch (visibility) {
  ProfilePrivacySettingsOverall.ovWide => t.divisions.level.ov.short,
  ProfilePrivacySettingsOverall.kvWide => t.divisions.level.kv.short,
  ProfilePrivacySettingsOverall.lvWide => t.divisions.level.lv.short,
  ProfilePrivacySettingsOverall.bvWide => t.divisions.level.bv.short,
  _ => visibilityLabel(visibility),
};

String visibilityHint(ProfilePrivacySettingsOverall visibility) => switch (visibility) {
  ProfilePrivacySettingsOverall.private => t.profiles.visibility.privateHint,
  ProfilePrivacySettingsOverall.ovWide => t.profiles.visibility.ovHint,
  ProfilePrivacySettingsOverall.public => t.profiles.visibility.publicHint,
  _ => t.profiles.visibility.divisionHint(division: visibilityLabel(visibility)),
};
