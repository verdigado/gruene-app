part of '../converters.dart';

extension FeatureExtension on turf.Feature {
  bool isVirtual() {
    if (properties == null) return false;
    var props = properties!;
    if (props[CampaignConstants.featurePropertyIsVirtual] == null) return false;
    return bool.parse(props[CampaignConstants.featurePropertyIsVirtual].toString());
  }
}

extension FeatureListExtension on List<turf.Feature> {
  turf.FeatureCollection asFeatureCollection() {
    return turf.FeatureCollection(features: this);
  }
}
