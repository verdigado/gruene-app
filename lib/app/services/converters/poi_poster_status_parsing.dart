part of '../converters.dart';

extension PoiPosterStatusParsing on PosterStatus {
  PosterModelStatus transformToModelPosterStatus() {
    return switch (this) {
      PosterStatus.ok => PosterModelStatus.ok,
      PosterStatus.damaged => PosterModelStatus.damaged,
      PosterStatus.missing => PosterModelStatus.missing,
      PosterStatus.removed => PosterModelStatus.removed,
      PosterStatus.toBeMoved => PosterModelStatus.toBeMoved,
      PosterStatus.swaggerGeneratedUnknown => throw UnimplementedError(),
    };
  }

  String translatePosterStatus() {
    return switch (this) {
      PosterStatus.ok => '',
      PosterStatus.damaged => t.campaigns.poster.status.damaged.label,
      PosterStatus.removed => t.campaigns.poster.status.removed.label,
      PosterStatus.missing => t.campaigns.poster.status.missing.label,
      PosterStatus.toBeMoved => t.campaigns.poster.status.to_be_moved.label,
      PosterStatus.swaggerGeneratedUnknown => throw UnimplementedError(),
    };
  }
}
