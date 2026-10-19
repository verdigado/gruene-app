part of '../converters.dart';

extension RouteStatusMapping on RouteStatus {
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
