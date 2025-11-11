part of '../converters.dart';

extension ActionAreaDetailModelParsing on ActionAreaDetailModel {
  ActionAreaUpdateModel asActionAreaUpdate() {
    return ActionAreaUpdateModel(id: id, status: status, actionAreaDetail: this);
  }

  turf.Feature<turf.Polygon> transformToFeatureItem() {
    return turf.Feature<turf.Polygon>(
      id: id,
      properties: {'status': status.value!.toLowerCase(), CampaignConstants.featurePropertyIsVirtual: isCached},
      geometry: polygon.asTurfPolygon(),
    );
  }
}
