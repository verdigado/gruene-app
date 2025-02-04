part of '../converters.dart';

extension PosterStatusParsing on PosterStatus {
  PoiPosterStatus transformToPoiPosterStatus() {
    return switch (this) {
      PosterStatus.ok => PoiPosterStatus.ok,
      PosterStatus.damaged => PoiPosterStatus.damaged,
      PosterStatus.missing => PoiPosterStatus.missing,
      PosterStatus.removed => PoiPosterStatus.removed,
      PosterStatus.toBeMoved => PoiPosterStatus.toBeMoved,
    };
  }

  String translatePosterStatus() => transformToPoiPosterStatus().translatePosterStatus();
}
