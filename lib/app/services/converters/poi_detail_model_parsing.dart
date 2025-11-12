part of '../converters.dart';

extension PoiDetailModelParsing on PoiDetailModel {
  turf.Feature<turf.Point> transformToFeatureItem() {
    return turf.Feature<turf.Point>(
      id: id,
      properties: <String, dynamic>{
        CampaignConstants.featurePropertyStatusType: status,
        CampaignConstants.featurePropertyIsVirtual: isVirtual,
      },
      geometry: location.asPoint(),
    );
  }
}

extension PoiDetailModelListParsing on List<PoiDetailModel> {
  List<turf.Feature> transformToFeatureList() {
    return map((m) => m.transformToFeatureItem()).toList();
  }
}
