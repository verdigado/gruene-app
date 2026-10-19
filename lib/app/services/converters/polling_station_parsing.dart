part of '../converters.dart';

extension PollingStationParsing on PollingStation {
  turf.Feature<turf.Point> toFeature() {
    return turf.Feature<turf.Point>(id: id, properties: {'description': description}, geometry: coords.toTurfPoint());
  }
}

extension PollingStationListParsing on List<PollingStation> {
  List<turf.Feature<turf.Point>> toFeatures() {
    return map((p) => p.toFeature()).toList();
  }
}
