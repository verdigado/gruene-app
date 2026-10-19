part of '../geo.dart';

extension FeatureCollectionBounds on turf.FeatureCollection<turf.Point> {
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
