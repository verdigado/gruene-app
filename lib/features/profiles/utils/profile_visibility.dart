import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

String visibilityLabel(Visibility visibility) => switch (visibility) {
  Visibility.private => t.profiles.visibility.private,
  Visibility.ovWide => t.divisions.level.ov.label,
  Visibility.kvWide => t.divisions.level.kv.label,
  Visibility.lvWide => t.divisions.level.lv.label,
  Visibility.bvWide => t.divisions.level.bv.label,
  Visibility.public => t.profiles.visibility.public,
  _ => '',
};

String visibilityShortLabel(Visibility visibility) => switch (visibility) {
  Visibility.ovWide => t.divisions.level.ov.short,
  Visibility.kvWide => t.divisions.level.kv.short,
  Visibility.lvWide => t.divisions.level.lv.short,
  Visibility.bvWide => t.divisions.level.bv.short,
  _ => visibilityLabel(visibility),
};

String visibilityHint(Visibility visibility) => switch (visibility) {
  Visibility.private => t.profiles.visibility.privateHint,
  Visibility.ovWide => t.profiles.visibility.ovHint,
  Visibility.public => t.profiles.visibility.publicHint,
  _ => t.profiles.visibility.divisionHint(division: visibilityLabel(visibility)),
};
