part of '../converters.dart';

extension PollingStationParsing on PollingStation {
  Feature<Point> transformToFeatureItem() {
    toPosition(List<double> point) => Position(point[0], point[1]);

    var position = toPosition(coords);
    return Feature(
      id: id,
      properties: {'description': description},
      geometry: Point(coordinates: position),
    );
  }
}

extension PollingStationListParsing on List<PollingStation> {
  FeatureCollection transformToFeatureCollection() {
    return FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}
