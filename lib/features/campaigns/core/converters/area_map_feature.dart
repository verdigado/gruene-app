part of '../converters.dart';

extension AreaListMapFeature on List<Area> {
  List<turf.Feature<turf.Polygon>> toFeatures() {
    return map((p) => p.toActionAreaDetail().toFeature()).toList();
  }
}
