part of '../converters.dart';

extension RouteDetailModelParsing on RouteDetailModel {
  RouteStatusUpdateModel asRouteStatusUpdate() {
    return RouteStatusUpdateModel(id: id, status: status, routeDetail: this);
  }

  RouteAssignmentUpdateModel asRouteAssignmentUpdate() {
    return RouteAssignmentUpdateModel(id: id, team: team, routeDetail: this);
  }

  turf.Feature<turf.LineString> transformToFeatureItem() {
    var visualIdentifierHelper = GetIt.I<VisualIdentifierHelper>();
    var visualIdentifierColor = visualIdentifierHelper.getVisualIdentifierById(
      visualIdentifierId,
      fallbackColor: CampaignConstants.routeDefaultColor,
    );
    return turf.Feature<turf.LineString>(
      id: id,
      properties: {
        CampaignConstants.featurePropertyStatus: status.value?.toLowerCase(),
        CampaignConstants.featurePropertyIsVirtual: isVirtual,
        CampaignConstants.featurePropertyIsAssigned: team != null,
        CampaignConstants.featurePropertyColor: visualIdentifierColor,
      },
      geometry: lineString.asTurfLine(),
    );
  }
}
