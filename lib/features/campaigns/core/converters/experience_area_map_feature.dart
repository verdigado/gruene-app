part of '../converters.dart';

extension ExperienceAreaMapFeature on ExperienceArea {
  turf.Feature<turf.Polygon> transformToFeatureItem() {
    return turf.Feature<turf.Polygon>(id: id, geometry: polygon.asTurfPolygon());
  }
}

extension ExperienceAreaListMapFeature on List<ExperienceArea> {
  List<turf.Feature<turf.Polygon>> transformToFeatureList() {
    return map((p) => p.transformToFeatureItem()).toList();
  }
}
