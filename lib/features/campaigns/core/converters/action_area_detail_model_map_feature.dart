part of '../converters.dart';

extension ActionAreaDetailModelMapFeature on ActionAreaDetailModel {
  turf.Feature<turf.Polygon> toFeature() {
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
        // shown in the selection dialog for overlapping action areas
        CampaignConstants.featurePropertyName: name,
        CampaignConstants.featurePropertyTypeLabel: type.toLabel(),
      },
      geometry: polygon.toTurfPolygon(),
    );
  }
}
