part of '../converters.dart';

extension RouteDetailModelMapping on RouteDetailModel {
  RouteStatusUpdateModel toRouteStatusUpdate() {
    return RouteStatusUpdateModel(id: id, status: status, routeDetail: this);
  }

  RouteAssignmentUpdateModel toRouteAssignmentUpdate() {
    return RouteAssignmentUpdateModel(id: id, team: team, routeDetail: this);
  }
}
