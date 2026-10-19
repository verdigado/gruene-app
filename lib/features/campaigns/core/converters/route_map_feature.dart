part of '../converters.dart';

extension RouteListMapFeature on List<Route> {
  List<turf.Feature<turf.LineString>> toFeatures() {
    return map((p) => p.toRouteDetail().toFeature()).toList();
  }
}
