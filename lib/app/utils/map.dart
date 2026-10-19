import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:maplibre_gl/maplibre_gl.dart';

/// Adds an asset image to the currently displayed style
Future<void> addImageFromAsset(
  MapLibreMapController controller,
  String name,
  String assetName, {
  bool sdfImage = false,
}) async {
  final bytes = await rootBundle.load(assetName);
  final list = bytes.buffer.asUint8List();
  return controller.addImage(name, list, sdfImage);
}

/// Adds an asset image to the currently displayed style with its main color swapped to
/// [hexColor] (e.g. `#008939`). All other colors (e.g. white details), the shape and the
/// alpha channel are kept. Pixels blending the main color with white (anti-aliasing) are
/// blended with the new color accordingly.
/// The main color is the most frequent opaque, saturated color of the image unless
/// [sourceHexColor] is given.
Future<void> addRecoloredImageFromAsset(
  MapLibreMapController controller,
  String name,
  String assetName,
  String hexColor, {
  String? sourceHexColor,
}) async {
  final bytes = await rootBundle.load(assetName);
  final image = image_lib.decodePng(bytes.buffer.asUint8List())!.convert(numChannels: 4);
  final source = sourceHexColor != null ? _parseHexColor(sourceHexColor) : _findMainColor(image);
  if (source == null) {
    return controller.addImage(name, image_lib.encodePng(image));
  }
  final target = _parseHexColor(hexColor);

  // Pixels are interpreted as white + t * (source - white). Pixels close to that line are
  // recolored to white + t * (target - white), everything else stays untouched.
  const white = 255.0;
  const tolerance = 40.0;
  final direction = [for (final c in source) c - white];
  final lengthSquared = direction.fold<double>(0, (sum, d) => sum + d * d);
  if (lengthSquared == 0) {
    return controller.addImage(name, image_lib.encodePng(image));
  }

  for (final pixel in image) {
    if (pixel.a == 0) continue;
    final offset = [pixel.r - white, pixel.g - white, pixel.b - white];
    final t = ((offset[0] * direction[0] + offset[1] * direction[1] + offset[2] * direction[2]) / lengthSquared).clamp(
      0.0,
      1.0,
    );
    var distanceSquared = 0.0;
    for (var i = 0; i < 3; i++) {
      final d = offset[i] - t * direction[i];
      distanceSquared += d * d;
    }
    if (t == 0 || distanceSquared > tolerance * tolerance) continue;
    pixel
      ..r = (white + t * (target[0] - white)).round()
      ..g = (white + t * (target[1] - white)).round()
      ..b = (white + t * (target[2] - white)).round();
  }
  return controller.addImage(name, image_lib.encodePng(image));
}

List<double> _parseHexColor(String hexColor) {
  final color = int.parse(hexColor.replaceFirst('#', ''), radix: 16);
  return [((color >> 16) & 0xFF).toDouble(), ((color >> 8) & 0xFF).toDouble(), (color & 0xFF).toDouble()];
}

/// Returns the most frequent opaque, saturated color of [image] or null if there is none
List<double>? _findMainColor(image_lib.Image image) {
  final counts = <int, int>{};
  for (final pixel in image) {
    if (pixel.a < 255) continue;
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    if (max - min < 32) continue; // skip grey-ish pixels like white or black
    final key = (r << 16) | (g << 8) | b;
    counts[key] = (counts[key] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  final key = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  return [((key >> 16) & 0xFF).toDouble(), ((key >> 8) & 0xFF).toDouble(), (key & 0xFF).toDouble()];
}
