import 'package:maplibre_gl/maplibre_gl.dart';

class CampaignConstants {
  static const dummyImageAssetName = 'assets/splash/logo_android12.png';
  static const doorAssetName = 'assets/symbols/doors/door.png';
  static const flyerAssetName = 'assets/symbols/flyer/flyer.png';
  static const posterOkAssetName = 'assets/symbols/posters/poster.png';
  static const posterDamagedAssetName = 'assets/symbols/posters/poster_damaged.png';
  static const posterMissingAssetName = 'assets/symbols/posters/poster_missing.png';
  static const posterRemovedAssetName = 'assets/symbols/posters/poster_removed.png';
  static const posterToBeMovedAssetName = 'assets/symbols/posters/poster_to_be_moved.png';
  static const addMarkerAssetName = 'assets/symbols/add_marker.svg';

  static const pollingStationAssetName = 'assets/symbols/polling_stations/pollingstation.png';

  static const markerSourceName = 'markers';
  static const markerLayerName = 'markerSymbols';

  static Map<int, String> scoreInfos = {
    1: 'Stufe 1: wenige Plakate aufhängen, keine Flyer verteilen, keine Haustüren',
    2: 'Stufe 2: mehr Plakate aufhängen, Flyer verteilen wenn Zeit, keine Haustüren',
    3: 'Stufe 3: viele Plakate aufhängen, Flyer verteilen, Haustüren wenn Zeit',
    4: 'Stufe 4: viele Plakate aufhängen, viele Flyer verteilen, Haustüren',
    5: 'Stufe 5: viele Plakate aufhängen, sehr viele Flyer verteilen, Haustüren auf jeden Fall',
  };

  static LatLngBounds viewBoxGermany = LatLngBounds(
    southwest: LatLng(46.8, 5.6),
    northeast: LatLng(55.1, 15.5),
  ); //typically boundaries of Germany;
  static LatLng centerGermany = LatLng(51.163361, 10.447683);
}
