part of '../converters.dart';

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

  UpdateRouteType asUpdateRouteType() {
    switch (this) {
      case RouteType.flyerSpot:
        return UpdateRouteType.flyerSpot;
      case RouteType.poster:
        return UpdateRouteType.poster;
      case RouteType.house:
        return UpdateRouteType.house;

      case RouteType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
