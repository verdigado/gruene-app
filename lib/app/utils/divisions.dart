import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension DivisionExtension on Division {
  String shortDisplayName() => level == DivisionLevel.bv ? name2 : '${level.value} $name2';
}

extension MembershipsExtension on List<DivisionMembership> {
  List<Division> divisions() => map((membership) => membership.division).toList();

  Division? partyDivision() => divisions().firstWhereOrNull((division) => division.hierarchy == 'GR');

  Division? gjDivision() => divisions().firstWhereOrNull((division) => division.hierarchy == 'GJ');

  Division? kpvDivision() => divisions().firstWhereOrNull((division) => division.hierarchy == 'KPV');

  List<ProfilePrivacySettingsOverall> profileVisibilityOptions() => [
    ProfilePrivacySettingsOverall.private,
    ...(partyDivision()?.level == DivisionLevel.ov ? [ProfilePrivacySettingsOverall.ovWide] : []),
    ProfilePrivacySettingsOverall.kvWide,
    ProfilePrivacySettingsOverall.lvWide,
    ProfilePrivacySettingsOverall.bvWide,
    ProfilePrivacySettingsOverall.public,
  ];
}

extension DivisionFilter on Iterable<Division> {
  List<Division> filterByLevel(DivisionLevel level) {
    final filtered = where((division) => division.level == level).toList();
    filtered.sort((a, b) => a.name2.compareTo(b.name2));
    return filtered;
  }

  Division bundesverband() => firstWhere((it) => it.divisionKey == '10000000');
}
