part of '../converters.dart';

extension RouteDetailModelParsing on RouteDetailModel {
  RouteUpdateModel asRouteUpdate() {
    return RouteUpdateModel(id: id, status: status, routeDetail: this);
  }
}
