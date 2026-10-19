part of '../converters.dart';

extension FocusAreaMapFeature on FocusArea {
  turf.Feature<turf.Polygon> toFeature() {
    var opacities = [0, 0.2, 0.4, 0.55, 0.8];
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
      geometry: polygon.toTurfPolygon(),
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

extension FocusAreaListMapFeature on List<FocusArea> {
  List<turf.Feature<turf.Polygon>> toFeatures() {
    return map((p) => p.toFeature()).toList();
  }
}
