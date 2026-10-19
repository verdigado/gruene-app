part of '../geo.dart';

extension PolygonMapping on Polygon {
  turf.Polygon toTurfPolygon() {
    var coordList = coordinates.map((x) => x.toPositionList()).toList();
    return turf.Polygon(coordinates: coordList);
  }
}
