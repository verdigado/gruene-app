part of '../converters.dart';

extension ExperienceAreaParsing on ExperienceArea {
  turf.Feature<turf.Polygon> transformToFeatureItem() {
    return turf.Feature<turf.Polygon>(id: id, geometry: polygon.asTurfPolygon());
  }
}

extension ExperienceAreaListParsing on List<ExperienceArea> {
  List<turf.Feature<turf.Polygon>> transformToFeatureList() {
    return map((p) => p.transformToFeatureItem()).toList();
  }
}
