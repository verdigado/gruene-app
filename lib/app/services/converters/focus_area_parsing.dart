part of '../converters.dart';

extension FocusAreaParsing on FocusArea {
  turf.Feature<turf.Polygon> transformToFeatureItem() {
    var opacities = [0, 0.15, 0.4, 0.55, 0.75];
    var scoreIndex = score.toInt() - 1;
    return turf.Feature<turf.Polygon>(
      id: id,
      properties: {
        CampaignConstants.focusAreaMapIdProperty: id.toString(),
        CampaignConstants.focusAreaMapScoreColorProperty: ThemeColors.focusAreaBaseColor.toHexStringRGB(),
        CampaignConstants.focusAreaMapScoreOpacityProperty: scoreIndex > opacities.length || scoreIndex < 0
            ? opacities.first
            : opacities[scoreIndex],
        CampaignConstants.focusAreaMapInfoProperty: description,
        CampaignConstants.focusAreaMapScoreInfoProperty: CampaignConstants.scoreInfos[score],
        CampaignConstants.focusAreaMapTypeProperty: getGenType().name,
      },
      geometry: polygon.asTurfPolygon(),
    );
  }

  FocusAreaType getGenType() {
    var attr = attributes as Map<String, dynamic>;
    if (attr.containsKey('activity1')) {
      return FocusAreaType.gen2;
    }
    return FocusAreaType.classic;
  }
}

enum FocusAreaType { classic, gen2 }

extension FocusAreaListParsing on List<FocusArea> {
  List<turf.Feature<turf.Polygon>> transformToFeatureList() {
    return map((p) => p.transformToFeatureItem()).toList();
  }
}
