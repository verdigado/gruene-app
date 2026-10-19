part of '../geo.dart';

extension TurfPolygonMapping on turf.Polygon {
  double toSquareKilometers() {
    return turf.area(this)! / 1_000_000;
  }
}
