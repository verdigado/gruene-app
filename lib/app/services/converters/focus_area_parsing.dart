part of '../converters.dart';

extension FocusAreaParsing on FocusArea {
  turf.Feature<turf.Polygon> transformToFeatureItem() {
    var opacities = [0, 0.15, 0.4, 0.55, 0.75];
    var scoreIndex = score.toInt() - 1;
    return turf.Feature<turf.Polygon>(
      id: id,
      properties: {
        'id': id.toString(),
        'score_color': ThemeColors.focusAreaBaseColor.toHexStringRGB(),
        'score_opacity': scoreIndex > opacities.length || scoreIndex < 0 ? opacities.first : opacities[scoreIndex],
        'info': description,
        'score_info': CampaignConstants.scoreInfos[score],
      },
      geometry: polygon.asTurfPolygon(),
    );
  }
}

extension FocusAreaListParsing on List<FocusArea> {
  turf.FeatureCollection transformToFeatureCollection() {
    return turf.FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}
