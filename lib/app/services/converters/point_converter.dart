part of '../converters.dart';

extension PointParsing on turf.Point {
  LatLng asLatLng() {
    return LatLng(coordinates.lat.toDouble(), coordinates.lng.toDouble());
  }
}
