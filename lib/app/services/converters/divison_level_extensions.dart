part of '../converters.dart';

extension DivisionLevelExtension on DivisionLevel {
  HierarchyLevel asV1DivisionsGetLevel() {
    switch (this) {
      case DivisionLevel.bv:
        return HierarchyLevel.bv;
      case DivisionLevel.lv:
        return HierarchyLevel.lv;
      case DivisionLevel.kv:
        return HierarchyLevel.kv;
      case DivisionLevel.ov:
        return HierarchyLevel.ov;
      case DivisionLevel.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
