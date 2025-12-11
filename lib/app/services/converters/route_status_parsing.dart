part of '../converters.dart';

extension RouteStatusParsing on RouteStatus {
  TeamRouteStatus asTeamRouteStatus() {
    switch (this) {
      case RouteStatus.open:
        return TeamRouteStatus.open;
      case RouteStatus.assigned:
        return TeamRouteStatus.assigned;
      case RouteStatus.closed:
        return TeamRouteStatus.closed;

      case RouteStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}

extension TeamRouteStatusParsing on TeamRouteStatus {
  UpdateRouteStatus asUpdateRouteStatus() {
    switch (this) {
      case TeamRouteStatus.open:
        return UpdateRouteStatus.open;
      case TeamRouteStatus.assigned:
        return UpdateRouteStatus.assigned;
      case TeamRouteStatus.closed:
        return UpdateRouteStatus.closed;

      case TeamRouteStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
