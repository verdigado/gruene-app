part of '../converters.dart';

extension PollingStationParsing on PollingStation {
  turf.Feature<turf.Point> transformToFeatureItem() {
    return turf.Feature<turf.Point>(id: id, properties: {'description': description}, geometry: coords.asTurfPoint());
  }
}

extension PollingStationListParsing on List<PollingStation> {
  List<turf.Feature<turf.Point>> transformToFeatureList() {
    return map((p) => p.transformToFeatureItem()).toList();
  }
}
