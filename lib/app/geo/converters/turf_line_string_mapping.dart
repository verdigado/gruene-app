part of '../geo.dart';

extension TurfLineStringMapping on turf.LineString {
  num toLength([turf.Unit unit = turf.Unit.meters]) {
    return turf.length(turf.Feature<turf.LineString>(geometry: this), unit);
  }
}
