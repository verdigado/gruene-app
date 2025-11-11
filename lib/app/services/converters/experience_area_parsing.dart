part of '../converters.dart';

extension ExperienceAreaParsing on ExperienceArea {
  turf.Feature<turf.Polygon> transformToFeatureItem() {
    return turf.Feature<turf.Polygon>(id: id, geometry: polygon.asTurfPolygon());
  }
}

extension ExperienceAreaListParsing on List<ExperienceArea> {
  turf.FeatureCollection transformToFeatureCollection() {
    return turf.FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}
