part of '../converters.dart';

extension RouteDetailModelParsing on RouteDetailModel {
  RouteUpdateModel asRouteUpdate() {
    return RouteUpdateModel(id: id, status: status, routeDetail: this);
  }

  RouteAssignmentUpdateModel asRouteAssignmentUpdate() {
    return RouteAssignmentUpdateModel(id: id, team: team, routeDetail: this);
  }

  turf.Feature<turf.LineString> transformToFeatureItem() {
    return turf.Feature<turf.LineString>(
      id: id,
      properties: {
        CampaignConstants.featurePropertyStatus: status.toString(),
        CampaignConstants.featurePropertyIsVirtual: isVirtual,
        CampaignConstants.featurePropertyIsAssigned: team != null,
      },
      geometry: lineString.asTurfLine(),
    );
  }
}
