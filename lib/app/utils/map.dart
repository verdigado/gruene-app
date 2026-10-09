import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/along.dart';

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

/// Adds an asset image to the currently displayed style with the color of all pixels swapped
/// to [hexColor] (e.g. `#008939`) while keeping their alpha channel
Future<void> addRecoloredImageFromAsset(
  MapLibreMapController controller,
  String name,
  String assetName,
  String hexColor,
) async {
  final bytes = await rootBundle.load(assetName);
  final image = image_lib.decodePng(bytes.buffer.asUint8List())!.convert(numChannels: 4);
  final color = int.parse(hexColor.replaceFirst('#', ''), radix: 16);
  final red = (color >> 16) & 0xFF;
  final green = (color >> 8) & 0xFF;
  final blue = color & 0xFF;
  for (final pixel in image) {
    pixel
      ..r = red
      ..g = green
      ..b = blue;
  }
  return controller.addImage(name, image_lib.encodePng(image));
}

extension FeatureCollectionExtension on FeatureCollection<Point> {
  LatLngBounds? get bounds {
    num? minLat, maxLat, minLng, maxLng;
    for (var feature in features) {
      final lat = feature.geometry?.coordinates.lat;
      final lng = feature.geometry?.coordinates.lng;

      minLat = (minLat == null || lat == null) ? lat : (lat < minLat ? lat : minLat);
      maxLat = (maxLat == null || lat == null) ? lat : (lat > maxLat ? lat : maxLat);
      minLng = (minLng == null || lng == null) ? lng : (lng < minLng ? lng : minLng);
      maxLng = (maxLng == null || lng == null) ? lng : (lng > maxLng ? lng : maxLng);
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return null;
    }

    return LatLngBounds(
      southwest: LatLng(minLat.toDouble(), minLng.toDouble()),
      northeast: LatLng(maxLat.toDouble(), maxLng.toDouble()),
    );
  }
}
