part of '../converters.dart';

extension TeamRouteTypeParsing on RouteType {
  String toLabel() {
    var typeLabel = switch (this) {
      RouteType.flyerSpot => t.campaigns.flyer.label,
      RouteType.poster => t.campaigns.poster.label,
      RouteType.house => t.campaigns.door.label,
      RouteType.swaggerGeneratedUnknown => throw UnimplementedError(),
    };
    return '$typeLabel-${t.campaigns.route.label}';
  }

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

extension TeamRouteStatusParsing on RouteStatus {
  RouteStatus toUpdateRouteStatusStatus() {
    switch (this) {
      case RouteStatus.open:
        return RouteStatus.open;
      case RouteStatus.closed:
        return RouteStatus.closed;

      case RouteStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
