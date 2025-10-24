part of '../converters.dart';

extension ActionAreaParsing on Area {
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

extension ActionAreaListParsing on List<Area> {
  FeatureCollection transformToFeatureCollection() {
    return FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}
