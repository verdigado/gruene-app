part of '../converters.dart';

extension RouteParsing on Route {
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
  List<turf.Feature<turf.LineString>> transformToFeatureList() {
    return map((p) => p.asRouteDetail().transformToFeatureItem()).toList();
  }
}
