part of '../converters.dart';

extension RouteStatusUpdateModelParsing on RouteStatusUpdateModel {
  RouteDetailModel toVirtualRouteDetailModel() {
    var newRouteDetail = routeDetail.copyWith(status: status, isVirtual: true);
    return newRouteDetail;
  }
}

extension RouteAssignmentUpdateModelParsing on RouteAssignmentUpdateModel {
  RouteDetailModel toVirtualRouteDetailModel() {
    var newRouteDetail = routeDetail.copyWith(team: Wrapped.value(team), isVirtual: true);
    return newRouteDetail;
  }
}
