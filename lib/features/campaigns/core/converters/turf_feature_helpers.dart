part of '../converters.dart';

extension TurfFeatureHelpers on turf.Feature {
  bool isVirtual() {
    if (properties == null) return false;
    var props = properties!;
    if (props[CampaignConstants.featurePropertyIsVirtual] == null) return false;
    return bool.parse(props[CampaignConstants.featurePropertyIsVirtual].toString());
  }
}

extension TurfFeatureListHelpers on List<turf.Feature> {
  turf.FeatureCollection asFeatureCollection() {
    return turf.FeatureCollection(features: this);
  }
}
