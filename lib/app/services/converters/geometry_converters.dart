part of '../converters.dart';

extension PolygonConverter on Polygon {
  turf.Polygon asTurfPolygon() {
    var coordList = coordinates.map((x) => x.toPositionList()).toList();
    return turf.Polygon(coordinates: coordList);
  }
}

extension LineStringConverter on LineString {
  turf.LineString asTurfLine() {
    var position = coordinates.toPositionList();
    return turf.LineString(coordinates: position);
  }
}

extension DoubleListParsing on List<double?>? {
  turf.Position toPosition() => turf.Position(this![0]!, this![1]!);
  turf.Point asTurfPoint() => turf.Point(coordinates: toPosition());
}

extension DoubleListListParsing on List<List<double?>?> {
  List<turf.Position> toPositionList() => map((p) => p.toPosition()).toList();
}
