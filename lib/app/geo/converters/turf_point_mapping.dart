part of '../geo.dart';

extension TurfPointMapping on turf.Point {
  LatLng toLatLng() {
    return LatLng(coordinates.lat.toDouble(), coordinates.lng.toDouble());
  }
}
