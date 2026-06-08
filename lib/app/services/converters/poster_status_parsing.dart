part of '../converters.dart';

extension PosterStatusParsing on PosterModelStatus {
  PosterStatus transformToPoiPosterStatus() {
    return switch (this) {
      PosterModelStatus.ok => PosterStatus.ok,
      PosterModelStatus.damaged => PosterStatus.damaged,
      PosterModelStatus.missing => PosterStatus.missing,
      PosterModelStatus.removed => PosterStatus.removed,
      PosterModelStatus.toBeMoved => PosterStatus.toBeMoved,
    };
  }

  String translatePosterStatus() => transformToPoiPosterStatus().translatePosterStatus();
}
