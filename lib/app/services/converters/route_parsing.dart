part of '../converters.dart';

extension RouteParsing on Route {
  turf.Feature<turf.LineString> transformToFeatureItem() {
    return turf.Feature<turf.LineString>(
      id: id,
      properties: {'status': status.toString()},
      geometry: lineString.asTurfLine(),
    );
  }

  RouteDetailModel asRouteDetail() {
    return RouteDetailModel(
      id: id,
      type: type,
      name: name,
      status: status,
      lineString: lineString,
      createdAt: createdAt.getAsLocalDateString(),
    );
  }
}

extension RouteListParsing on List<Route> {
  turf.FeatureCollection transformToFeatureCollection() {
    return turf.FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}
