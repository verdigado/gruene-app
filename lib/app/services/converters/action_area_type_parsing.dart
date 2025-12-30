part of '../converters.dart';

extension ActionAreaTypeParsing on AreaType {
  String getAsLabel() {
    var typeLabel = switch (this) {
      AreaType.flyerSpot => t.campaigns.flyer.label,
      AreaType.house => t.campaigns.door.label,
      AreaType.poster => t.campaigns.poster.label,
      AreaType.swaggerGeneratedUnknown => throw UnimplementedError(),
    };
    return '$typeLabel-${t.campaigns.action_area.label}';
  }
}
