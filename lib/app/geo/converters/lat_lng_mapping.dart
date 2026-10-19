part of '../geo.dart';

extension LatLngMapping on LatLng {
  String toLngLatString() {
    return toGeoJsonCoords().join(',');
  }

  List<double> toGeoJsonCoords() {
    return [longitude, latitude];
  }

  List<double> toGeoJsonBBox(LatLng northEast) {
    final southWest = this;
    final coords = southWest.toGeoJsonCoords();
    coords.addAll(northEast.toGeoJsonCoords());
    return coords;
  }

  String toGeoJsonBBoxString(LatLng northEast) {
    return toGeoJsonBBox(northEast).join(',');
  }

  num getDistance(LatLng other) {
    return turf.distance(toPoint(), other.toPoint(), turf.Unit.kilometers);
  }

  turf.Point toPoint() {
    return turf.Point(coordinates: turf.Position(longitude, latitude));
  }
}
