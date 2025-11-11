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

  static const experienceAreaFillPatternAssetName = 'assets/maps/layer_styles/experience_area_16x16.png';
  static const actionAreaFillPatternAssetName = 'assets/maps/layer_styles/action_area_16x16.png';

  static const poiMarkerSourceId = 'poi_markers';
  static const markerSelectedSourceId = '${poiMarkerSourceId}_selected';
  static const markerLayerId = 'marker_symbols';
  static const markerSelectedLayerId = '${markerLayerId}_selected';

  static const focusAreaSourceName = 'focusArea';
  static const focusAreaBorderLayerId = 'focusArea_border';
  static const focusAreaFillLayerId = 'focusArea_layer';

  static const pollingStationSourceName = 'pollingStation';
  static const pollingStationSelectedSourceName = 'pollingStation_selected';
  static const pollingStationSymbolLayerId = 'pollingStation_layer';
  static const pollingStationSymbolSelectedLayerId = 'pollingStation_layer_selected';

  static const routesSourceName = 'routes';
  static const routesSelectedSourceName = 'routes_selected';
  static const routesLineLayerId = 'routes_layer';
  static const routesLineSelectedLayerId = 'routes_layer_selected';

  static const experienceAreaSourceName = 'experience_areas';
  static const experienceAreaSelectedSourceName = 'experience_areas_selected';
  static const experienceAreaLayerId = 'experience_areas_layer';
  static const experienceAreaOutlineLayerId = '${experienceAreaLayerId}_line';
  static const experienceAreaSelectedLayerId = 'experience_areas_layer_selected';
  static const experienceAreaSelectedOutlineLayerId = '${experienceAreaSelectedLayerId}_line';

  static const actionAreaSourceName = 'action_areas';
  static const actionAreaSelectedSourceName = 'action_areas_selected';
  static const actionAreaLayerId = 'action_areas_layer';
  static const actionAreaOutlineLayerId = '${actionAreaLayerId}_line';
  // static const actionAreaSelectedLayerId = 'action_areas_layer_selected';
  static const actionAreaSelectedOutlineLayerId = '${actionAreaOutlineLayerId}_selected';

  static Map<int, String> scoreInfos = {
    1: 'Stufe 1: wenige Plakate aufhängen, keine Flyer verteilen, keine Haustüren',
    2: 'Stufe 2: mehr Plakate aufhängen, Flyer verteilen wenn Zeit, keine Haustüren',
    3: 'Stufe 3: viele Plakate aufhängen, Flyer verteilen, Haustüren wenn Zeit',
    4: 'Stufe 4: viele Plakate aufhängen, viele Flyer verteilen, Haustüren',
    5: 'Stufe 5: viele Plakate aufhängen, sehr viele Flyer verteilen, Haustüren auf jeden Fall',
  };

  static const featurePropertyStatusType = 'status_type';
  static const featurePropertyIsVirtual = 'is_virtual';

  static LatLngBounds viewBoxGermany = LatLngBounds(
    southwest: LatLng(46.8, 5.6),
    northeast: LatLng(55.1, 15.5),
  ); //typically boundaries of Germany;
  static LatLng centerGermany = LatLng(51.163361, 10.447683);
}
