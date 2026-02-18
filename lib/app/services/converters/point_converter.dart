part of '../converters.dart';

extension PointParsing on turf.Point {
  LatLng asLatLng() {
    return LatLng(coordinates.lat.toDouble(), coordinates.lng.toDouble());
  }
}

extension WidgetExtension on Widget {
  Widget disable() {
    return Stack(
      children: [
        this,
        Positioned.fill(child: Container(color: ThemeColors.disabledShadow.withAlpha(170))),
      ],
    );
  }
}
