import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension DivisionExtension on Division {
  String get shortDisplayName => level == DivisionLevel.bv ? name2 : '${level.value} $name2';

  String get displayName => level == DivisionLevel.bv ? name2 : '$name1 $name2';
}

extension SortExtension on List<Division> {
  List<Division> sortByLevel() {
    sort((a, b) {
      if (a.hierarchy != b.hierarchy) {
        // Sort party > GJ > KPV
        return int.parse(a.divisionKey[0]) - int.parse(b.divisionKey[0]);
      }
      if (a.level != b.level) {
        // Sort BV > LVs > KVs > OVs
        return a.level.granularity - b.level.granularity;
      }
      // Sort alphabetical
      return a.name2.compareTo(b.name2);
    });
    return this;
  }
}

extension FilterExtension on Iterable<Division> {
  List<Division> filter(String query) => where(
    (division) =>
        division.displayName.normalized.contains(query.normalized) ||
        division.shortDisplayName.normalized.contains(query.normalized),
  ).toList().sortByLevel();

  List<Division> filterByLevel(DivisionLevel level) {
    final filtered = where((division) => division.level == level).toList();
    filtered.sort((a, b) => a.name2.compareTo(b.name2));
    return filtered;
  }

  Division bundesverband() => firstWhere((it) => it.divisionKey == '10000000');
}

extension DivisionLevelExtension on DivisionLevel {
  int get granularity => switch (this) {
    DivisionLevel.bv => 0,
    DivisionLevel.lv => 1,
    DivisionLevel.kv => 2,
    DivisionLevel.ov => 3,
    _ => 4,
  };
}
