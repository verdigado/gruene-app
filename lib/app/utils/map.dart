import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/along.dart';

/// Adds an asset image to the currently displayed style
Future<void> addImageFromAsset(MapLibreMapController controller, String name, String assetName) async {
  final bytes = await rootBundle.load(assetName);
  final list = bytes.buffer.asUint8List();
  return controller.addImage(name, list);
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
