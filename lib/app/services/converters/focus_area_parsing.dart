part of '../converters.dart';

extension FocusAreaParsing on FocusArea {
  Feature<turf.Polygon> transformToFeatureItem() {
    toPosition(List<double?>? point) => Position(point![0]!, point[1]!);
    toPositionList(List<List<double?>?> points) => points.map(toPosition).toList();

    var coordList = polygon.coordinates.map(toPositionList).toList();

    var opacities = [0, 0.15, 0.4, 0.55, 0.75];
    var scoreIndex = score.toInt() - 1;
    return Feature<turf.Polygon>(
      id: id,
      properties: {
        'id': id.toString(),
        'score_color': ThemeColors.focusAreaBaseColor.toHexStringRGB(),
        'score_opacity': scoreIndex > opacities.length || scoreIndex < 0 ? opacities.first : opacities[scoreIndex],
        'info': description,
        'score_info': CampaignConstants.scoreInfos[score],
      },
      geometry: turf.Polygon(coordinates: coordList),
    );
  }
}

extension FocusAreaListParsing on List<FocusArea> {
  FeatureCollection transformToFeatureCollection() {
    return FeatureCollection(features: map((p) => p.transformToFeatureItem()).toList());
  }
}
