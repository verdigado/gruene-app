import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension DivisionExtension on Division {
  String shortDisplayName() => level == DivisionLevel.bv ? name2 : '${level.value} $name2';
}

extension DivisionFilter on Iterable<Division> {
  List<Division> filterByLevel(DivisionLevel level) {
    final filtered = where((division) => division.level == level).toList();
    filtered.sort((a, b) => a.name2.compareTo(b.name2));
    return filtered;
  }

  Division bundesverband() => firstWhere((it) => it.divisionKey == '10000000');
}
