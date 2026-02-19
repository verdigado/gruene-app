part of '../converters.dart';

extension DivisionLevelExtension on DivisionLevel {
  V1DivisionsGetLevel asV1DivisionsGetLevel() {
    switch (this) {
      case DivisionLevel.bv:
        return V1DivisionsGetLevel.bv;
      case DivisionLevel.lv:
        return V1DivisionsGetLevel.lv;
      case DivisionLevel.kv:
        return V1DivisionsGetLevel.kv;
      case DivisionLevel.ov:
        return V1DivisionsGetLevel.ov;
      case DivisionLevel.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
