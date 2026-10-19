part of '../converters.dart';

extension PoiDetailModelMapFeature on PoiDetailModel {
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

extension PoiDetailModelListMapFeature on List<PoiDetailModel> {
  List<turf.Feature> transformToFeatureList() {
    return map((m) => m.transformToFeatureItem()).toList();
  }
}
