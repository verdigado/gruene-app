part of '../converters.dart';

extension ExperienceAreaMapFeature on ExperienceArea {
  turf.Feature<turf.Polygon> toFeature() {
    return turf.Feature<turf.Polygon>(id: id, geometry: polygon.toTurfPolygon());
  }
}

extension ExperienceAreaListMapFeature on List<ExperienceArea> {
  List<turf.Feature<turf.Polygon>> toFeatures() {
    return map((p) => p.toFeature()).toList();
  }
}
