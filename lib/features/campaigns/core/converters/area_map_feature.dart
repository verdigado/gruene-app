part of '../converters.dart';

extension AreaListMapFeature on List<Area> {
  List<turf.Feature<turf.Polygon>> transformToFeatureList() {
    return map((p) => p.asActionAreaDetail().transformToFeatureItem()).toList();
  }
}
