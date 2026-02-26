part of '../converters.dart';

extension ActionAreaDetailModelParsing on ActionAreaDetailModel {
  ActionAreaStatusUpdateModel asActionAreaUpdate() {
    return ActionAreaStatusUpdateModel(id: id, status: status, actionAreaDetail: this);
  }

  ActionAreaAssignmentUpdateModel asActionAreaAssignmentUpdate() {
    return ActionAreaAssignmentUpdateModel(id: id, team: team, actionAreaDetail: this);
  }

  turf.Feature<turf.Polygon> transformToFeatureItem() {
    return turf.Feature<turf.Polygon>(
      id: id,
      properties: {
        CampaignConstants.featurePropertyStatus: status.value!.toLowerCase(),
        CampaignConstants.featurePropertyIsVirtual: isVirtual,
        CampaignConstants.featurePropertyIsAssigned: team != null,
      },
      geometry: polygon.asTurfPolygon(),
    );
  }
}
