part of '../converters.dart';

extension TeamRouteParsing on Route {
  RouteDetailModel asRouteDetail() {
    return RouteDetailModel(
      id: id,
      type: type,
      name: name,
      status: status,
      lineString: lineString,
      createdAt: createdAt.getAsLocalDateString(),
      team: team,
    );
  }
}

extension RouteListParsing on List<Route> {
  List<turf.Feature<turf.LineString>> transformToFeatureList() {
    return map((p) => p.asRouteDetail().transformToFeatureItem()).toList();
  }
}

extension RouteTypeParsing on RouteType {
  RouteType asTeamRouteType() {
    switch (this) {
      case RouteType.flyerSpot:
        return RouteType.flyerSpot;
      case RouteType.poster:
        return RouteType.poster;
      case RouteType.house:
        return RouteType.house;
      case RouteType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
