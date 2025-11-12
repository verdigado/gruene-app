part of '../converters.dart';

extension RouteUpdateModelParsing on RouteUpdateModel {
  RouteDetailModel transformToVirtualRouteDetailModel() {
    var newRouteDetail = routeDetail.copyWith(status: status, isVirtual: true);
    return newRouteDetail;
  }
}
