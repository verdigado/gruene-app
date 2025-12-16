part of '../converters.dart';

extension RouteParsing on Route {
  RouteDetailModel asRouteDetail() {
    return RouteDetailModel(
      id: id,
      type: type.asTeamRouteType(),
      name: name,
      status: status.asTeamRouteStatus(),
      lineString: lineString,
      createdAt: createdAt.getAsLocalDateString(),
      team: null,
    );
  }
}

extension TeamRouteParsing on TeamRoute {
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
  TeamRouteType asTeamRouteType() {
    switch (this) {
      case RouteType.flyerSpot:
        return TeamRouteType.flyerSpot;
      case RouteType.poster:
        return TeamRouteType.poster;
      case RouteType.house:
        return TeamRouteType.house;
      case RouteType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
