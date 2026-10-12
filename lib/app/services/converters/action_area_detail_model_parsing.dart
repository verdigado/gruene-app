// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../converters.dart';

extension ActionAreaDetailModelParsing on ActionAreaDetailModel {
  ActionAreaStatusUpdateModel asActionAreaUpdate() {
    return ActionAreaStatusUpdateModel(id: id, status: status, actionAreaDetail: this);
  }

  ActionAreaAssignmentUpdateModel asActionAreaAssignmentUpdate() {
    return ActionAreaAssignmentUpdateModel(id: id, team: team, actionAreaDetail: this);
  }

  turf.Feature<turf.Polygon> transformToFeatureItem() {
    var visualIdentifierHelper = GetIt.I<VisualIdentifierHelper>();
    var visualIdentifierColor = visualIdentifierHelper.getVisualIdentifierById(
      visualIdentifierId,
      fallbackColor: CampaignConstants.routeDefaultColor,
    );
    return turf.Feature<turf.Polygon>(
      id: id,
      properties: {
        CampaignConstants.featurePropertyStatus: status.value!.toLowerCase(),
        CampaignConstants.featurePropertyIsVirtual: isVirtual,
        CampaignConstants.featurePropertyIsAssigned: team != null,
        CampaignConstants.featurePropertyVisualIdentifierId: visualIdentifierId,
        CampaignConstants.featurePropertyColor: visualIdentifierColor,
      },
      geometry: polygon.asTurfPolygon(),
    );
  }
}
