part of '../converters.dart';

extension PosterModelStatusMapping on PosterModelStatus {
  PosterStatus toPoiPosterStatus() {
    return switch (this) {
      PosterModelStatus.ok => PosterStatus.ok,
      PosterModelStatus.damaged => PosterStatus.damaged,
      PosterModelStatus.missing => PosterStatus.missing,
      PosterModelStatus.removed => PosterStatus.removed,
      PosterModelStatus.toBeMoved => PosterStatus.toBeMoved,
    };
  }

  String translatePosterStatus() => toPoiPosterStatus().translatePosterStatus();
}
