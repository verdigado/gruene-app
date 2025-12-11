part of '../converters.dart';

extension TeamRouteTypeParsing on TeamRouteType {
  String getAsLabel() {
    var typeLabel = switch (this) {
      TeamRouteType.flyerSpot => t.campaigns.flyer.label,
      TeamRouteType.poster => t.campaigns.poster.label,
      TeamRouteType.house => t.campaigns.door.label,
      TeamRouteType.swaggerGeneratedUnknown => throw UnimplementedError(),
    };
    return '$typeLabel-${t.campaigns.route.label}';
  }

  UpdateRouteType asUpdateRouteType() {
    switch (this) {
      case TeamRouteType.flyerSpot:
        return UpdateRouteType.flyerSpot;
      case TeamRouteType.poster:
        return UpdateRouteType.poster;
      case TeamRouteType.house:
        return UpdateRouteType.house;

      case TeamRouteType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
