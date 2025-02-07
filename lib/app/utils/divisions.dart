import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension DivisionFilter on Iterable<Division> {
  List<Division> filterAndSortByLevel(DivisionLevel level) {
    final filtered = where((division) => division.level == level).toList();
    filtered.sort((a, b) => a.name2.compareTo(b.name2));
    return filtered;
  }

  Division bundesverband() => filterAndSortByLevel(DivisionLevel.bv).first;
}
