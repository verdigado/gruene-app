part of '../converters.dart';

extension RouteTypeMapping on RouteType {
  RouteType toUpdateRouteType() {
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
