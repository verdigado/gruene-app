part of '../converters.dart';

extension RouteAssignmentUpdateModelMapping on RouteAssignmentUpdateModel {
  RouteDetailModel toVirtualRouteDetailModel() {
    var newRouteDetail = routeDetail.copyWith(team: Wrapped.value(team), isVirtual: true);
    return newRouteDetail;
  }
}
