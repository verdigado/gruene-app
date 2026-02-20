import 'package:gruene_app/app/utils/division_level_segment_lengths.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class DivisionKey {
  final String key;
  DivisionKey(this.key) {
    if (key.length != 8) {
      throw ArgumentError('Invalid division key: $key');
    }
  }

  String getParentKey(DivisionLevel level) {
    var divisionLevelLength = DivisionLevelSegmentLengths.fromDivisionLevel(level).length;
    return key.substring(0, divisionLevelLength).padRight(DivisionLevelSegmentLengths.ov.length, '0');
  }
}
