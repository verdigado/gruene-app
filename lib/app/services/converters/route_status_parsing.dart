part of '../converters.dart';

extension RouteStatusParsing on RouteStatus {
  UpdateRouteStatus asUpdateRouteStatus() {
    switch (this) {
      case RouteStatus.open:
        return UpdateRouteStatus.open;
      case RouteStatus.assigned:
        return UpdateRouteStatus.assigned;
      case RouteStatus.closed:
        return UpdateRouteStatus.closed;

      case RouteStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
