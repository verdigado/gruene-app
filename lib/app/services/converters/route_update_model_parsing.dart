part of '../converters.dart';

extension RouteUpdateModelParsing on RouteUpdateModel {
  RouteDetailModel transformToVirtualRouteDetailModel() {
    var newRouteDetail = routeDetail.copyWith(status: status, isVirtual: true);
    return newRouteDetail;
  }
}

extension RouteAssignmentUpdateModelParsing on RouteAssignmentUpdateModel {
  RouteDetailModel transformToVirtualRouteDetailModel() {
    var newRouteDetail = routeDetail.copyWith(team: team, isVirtual: true);
    return newRouteDetail;
  }
}
