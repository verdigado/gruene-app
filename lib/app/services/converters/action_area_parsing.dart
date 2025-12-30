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
      team: team,
    );
  }
}

extension ActionAreaListParsing on List<Area> {
  List<turf.Feature<turf.Polygon>> transformToFeatureList() {
    return map((p) => p.asActionAreaDetail().transformToFeatureItem()).toList();
  }
}
