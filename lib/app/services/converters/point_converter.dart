part of '../converters.dart';

extension PointParsing on turf.Point {
  LatLng toLatLng() {
    return LatLng(coordinates.lat.toDouble(), coordinates.lng.toDouble());
  }
}
