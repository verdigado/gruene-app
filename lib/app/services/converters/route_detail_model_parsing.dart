part of '../converters.dart';

extension RouteDetailModelParsing on RouteDetailModel {
  RouteUpdateModel asRouteUpdate() {
    return RouteUpdateModel(id: id, status: status, routeDetail: this);
  }

  turf.Feature<turf.LineString> transformToFeatureItem() {
    return turf.Feature<turf.LineString>(
      id: id,
      properties: {'status': status.toString()},
      geometry: lineString.asTurfLine(),
    );
  }
}
