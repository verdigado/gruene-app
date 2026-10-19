part of '../converters.dart';

extension RouteDetailModelMapFeature on RouteDetailModel {
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
        CampaignConstants.featurePropertyVisualIdentifierId: visualIdentifierId,
      },
      geometry: lineString.asTurfLine(),
    );
  }
}
