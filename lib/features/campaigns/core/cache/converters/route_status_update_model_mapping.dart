part of '../converters.dart';

extension RouteStatusUpdateModelMapping on RouteStatusUpdateModel {
  RouteDetailModel toVirtualRouteDetailModel() {
    var newRouteDetail = routeDetail.copyWith(status: status, isVirtual: true);
    return newRouteDetail;
  }
}
