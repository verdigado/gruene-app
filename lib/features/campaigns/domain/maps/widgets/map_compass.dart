import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

/// Compass rendered in flutter as the native MapLibre compass is only refreshed on the next map redraw
class MapCompass extends StatelessWidget {
  /// The camera's bearing in degrees, measured clockwise from north
  final double bearing;
  final VoidCallback onPressed;

  const MapCompass({super.key, required this.bearing, required this.onPressed});

  static bool isNorthed(double bearing) {
    final normalizedBearing = bearing % 360;
    return normalizedBearing < 0.5 || normalizedBearing > 359.5;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isNorthed(bearing) ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: isNorthed(bearing),
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: ThemeColors.background,
            shape: CircleBorder(side: BorderSide(color: ThemeColors.textDisabled)),
            padding: const EdgeInsets.all(6),
          ),
          icon: Transform.rotate(
            angle: -bearing * pi / 180,
            child: Icon(Icons.navigation, color: ThemeColors.textDisabled),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
