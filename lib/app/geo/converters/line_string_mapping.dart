part of '../geo.dart';

extension LineStringMapping on LineString {
  turf.LineString toTurfLine() {
    var position = coordinates.toPositionList();
    return turf.LineString(coordinates: position);
  }
}
