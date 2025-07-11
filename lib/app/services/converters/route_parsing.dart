part of '../converters.dart';

extension RouteParsing on Route {
  turf.Feature<turf.LineString> transformToFeatureItem() {
    toPosition(List<double?> point) => Position(point[0]!, point[1]!);
    toLineString(List<List<double?>> line) => line.map(toPosition).toList();

    var position = toLineString(lineString.coordinates);
    return turf.Feature<turf.LineString>(
      id: id,
      properties: {'status': status.toString()},
      geometry: turf.LineString(coordinates: position),
    );
  }
}

extension RouteListParsing on List<Route> {
  FeatureCollection transformToFeatureCollection() {
    return FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}

extension RouteTypeParsing on RouteType {
  String getAsLabel() {
    var typeLabel = switch (this) {
      RouteType.flyerSpot => t.campaigns.flyer.label,
      RouteType.poster => t.campaigns.poster.label,
      RouteType.house => t.campaigns.door.label,
      RouteType.swaggerGeneratedUnknown => throw UnimplementedError(),
    };
    return '$typeLabel-${t.campaigns.route.label}';
  }
}
