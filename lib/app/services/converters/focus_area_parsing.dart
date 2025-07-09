part of '../converters.dart';

extension FocusAreaParsing on FocusArea {
  MapLayerModel transformToMapLayer() {
    toPosition(List<double?>? point) => Position(point![0]!, point[1]!);
    toPositionList(List<List<double?>?> points) => points.map(toPosition).toList();

    var coordList = polygon.coordinates.map(toPositionList).toList();
    return MapLayerModel(id: id, coords: coordList, score: score, description: description);
  }
}
