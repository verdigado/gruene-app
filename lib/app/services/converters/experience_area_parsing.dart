part of '../converters.dart';

extension ExperienceAreaParsing on ExperienceArea {
  turf.Feature<turf.Polygon> transformToFeatureItem() {
    toPosition(List<double?>? point) => Position(point![0]!, point[1]!);
    toPositionList(List<List<double?>?> points) => points.map(toPosition).toList();

    var coordList = polygon.coordinates.map(toPositionList).toList();
    return turf.Feature<turf.Polygon>(
      id: id,
      geometry: turf.Polygon(coordinates: coordList),
    );
  }
}

extension ExperienceAreaListParsing on List<ExperienceArea> {
  FeatureCollection transformToFeatureCollection() {
    return FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}
