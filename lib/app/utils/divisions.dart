import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension DivisionExtension on Division {
  String get shortDisplayName => level == HierarchyLevel.bv ? name2 : '${level.value} $name2';

  String get displayName => level == HierarchyLevel.bv ? name2 : '$name1 $name2';

  // Includes implicit members (i.e. child divisions), e.g. when searching for profiles in the API
  // Example: LV NRW: 11000000 -> 110, includes child KVs and OVs but not e.g. LV Rheinland-Pfalz (11000000)
  String get implicitMembersDivisionKey => divisionKey.substring(0, level.segmentLength);

  String parentDivisionKey(HierarchyLevel level) =>
      divisionKey.substring(0, level.segmentLength).padRight(divisionKey.length, '0');

  bool matches(String query) =>
      displayName.normalized.contains(query.normalized) || shortDisplayName.normalized.contains(query.normalized);
}

extension SortExtension on List<Division> {
  List<Division> sortByLevel({bool reverseLevel = false}) {
    final divisions = this;
    divisions.sort((a, b) {
      if (a.hierarchy != b.hierarchy) {
        // Sort party > GJ > KPV
        return int.parse(a.divisionKey[0]) - int.parse(b.divisionKey[0]);
      }
      if (a.level != b.level) {
        // Sort BV > LVs > KVs > OVs
        final granularity = a.level.granularity - b.level.granularity;
        return reverseLevel ? -granularity : granularity;
      }
      // Sort alphabetical
      return a.name2.compareTo(b.name2);
    });
    return divisions;
  }
}

extension FilterExtension on Iterable<Division> {
  List<Division> filter(String query) => where((division) => division.matches(query)).toList().sortByLevel();

  List<Division> filterByLevel(HierarchyLevel level) {
    final filtered = where((division) => division.level == level).toList();
    filtered.sort((a, b) => a.name2.compareTo(b.name2));
    return filtered;
  }

  Division get bundesverband => firstWhere((it) => it.divisionKey == '10000000');
}

extension HierarchyLevelExtension on HierarchyLevel {
  int get granularity => switch (this) {
    HierarchyLevel.bv => 0,
    HierarchyLevel.lv => 1,
    HierarchyLevel.kv => 2,
    HierarchyLevel.ov => 3,
    HierarchyLevel.swaggerGeneratedUnknown => 99,
  };

  int get segmentLength => switch (this) {
    HierarchyLevel.bv => 1,
    HierarchyLevel.lv => 3,
    HierarchyLevel.kv => 6,
    HierarchyLevel.ov => 8,
    HierarchyLevel.swaggerGeneratedUnknown => 8,
  };
}
