part of '../converters.dart';

extension BBoxConverter on turf.BBox {
  LatLng getSouthWest() => LatLng(lat1.toDouble(), lng1.toDouble());
  LatLng getNorthEast() => LatLng(lat2.toDouble(), lng2.toDouble());

  turf.BBox scale(double factor) {
    var originCoord = turf.centroid(turf.bboxPolygon(this)).geometry;
    var southwest = getSouthWest();
    var northeast = getNorthEast();

    turf.Position getNewCoord(LatLng coord) {
      var currentCoordAsPoint = coord.asPoint();
      var originalDistance = turf.rhumbDistance(originCoord!, currentCoordAsPoint);
      var bearing = turf.rhumbBearing(originCoord, currentCoordAsPoint);
      var newDistance = originalDistance * factor;
      var newCoord = turf.getCoord(turf.rhumbDestination(originCoord, newDistance, bearing));
      return newCoord;
    }

    var newSouthWest = getNewCoord(southwest);
    var newNorthEast = getNewCoord(northeast);
    return turf.bbox(turf.LineString(coordinates: [newSouthWest, newNorthEast]));
  }
}
