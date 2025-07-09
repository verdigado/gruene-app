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
    return distance(asPoint(), other.asPoint(), Unit.kilometers);
  }

  Point asPoint() {
    return Point(coordinates: Position(longitude, latitude));
  }
}
