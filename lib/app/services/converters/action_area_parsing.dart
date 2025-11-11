part of '../converters.dart';

extension ActionAreaParsing on Area {
  ActionAreaDetailModel asActionAreaDetail() {
    return ActionAreaDetailModel(
      id: id,
      type: type,
      comment: comment,
      name: name,
      status: status,
      polygon: polygon,
      createdAt: createdAt.getAsLocalDateString(),
    );
  }
}

extension ActionAreaListParsing on List<Area> {
  turf.FeatureCollection transformToFeatureCollection() {
    return turf.FeatureCollection(features: map((p) => p.asActionAreaDetail().transformToFeatureItem()).toList());
  }
}
