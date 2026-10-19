part of '../converters.dart';

extension RouteDetailModelMapping on RouteDetailModel {
  RouteStatusUpdateModel asRouteStatusUpdate() {
    return RouteStatusUpdateModel(id: id, status: status, routeDetail: this);
  }

  RouteAssignmentUpdateModel asRouteAssignmentUpdate() {
    return RouteAssignmentUpdateModel(id: id, team: team, routeDetail: this);
  }
}
