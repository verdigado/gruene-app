part of '../converters.dart';

extension PoiDetailModelMapFeature on PoiDetailModel {
  turf.Feature<turf.Point> toFeature() {
    return turf.Feature<turf.Point>(
      id: id,
      properties: <String, dynamic>{
        CampaignConstants.featurePropertyStatusType: status,
        CampaignConstants.featurePropertyIsVirtual: isVirtual,
      },
      geometry: location.toPoint(),
    );
  }
}

extension PoiDetailModelListMapFeature on List<PoiDetailModel> {
  List<turf.Feature> toFeatures() {
    return map((m) => m.toFeature()).toList();
  }
}
