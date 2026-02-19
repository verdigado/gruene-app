import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

enum DivisionLevelSegmentLengths {
  bv(1),
  lv(3),
  kv(6),
  ov(8);

  const DivisionLevelSegmentLengths(this.length);
  final int length;

  static DivisionLevelSegmentLengths fromDivisionLevel(DivisionLevel level) {
    switch (level) {
      case DivisionLevel.bv:
        return bv;
      case DivisionLevel.lv:
        return lv;
      case DivisionLevel.kv:
        return kv;
      case DivisionLevel.ov:
        return ov;
      case DivisionLevel.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
