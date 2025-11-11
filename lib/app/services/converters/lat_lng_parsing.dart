part of '../converters.dart';

extension LatLngParsing on LatLng {
  String toLngLatString() {
    return transformToGeoJsonCoords().join(',');
  }

  List<double> transformToGeoJsonCoords() {
    return [longitude, latitude];
  }

  List<double> transformToGeoJsonBBox(LatLng northEast) {
    final southWest = this;
    final coords = southWest.transformToGeoJsonCoords();
    coords.addAll(northEast.transformToGeoJsonCoords());
    return coords;
  }

  String transformToGeoJsonBBoxString(LatLng northEast) {
    return transformToGeoJsonBBox(northEast).join(',');
  }

  num getDistance(LatLng other) {
    return turf.distance(asPoint(), other.asPoint(), turf.Unit.kilometers);
  }

  turf.Point asPoint() {
    return turf.Point(coordinates: turf.Position(longitude, latitude));
  }
}
