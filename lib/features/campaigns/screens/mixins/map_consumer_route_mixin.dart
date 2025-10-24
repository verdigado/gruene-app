part of '../mixins.dart';

mixin MapConsumerRouteMixin on InfoBox {
  bool routesVisible = false;
  GrueneApiCampaignsPoiBaseService get campaignService;
  void hideCurrentSnackBar();
  void showInfoToast(String toastText, {void Function()? moreInfoCallback});

  Future<void> addRouteLayer(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final data = turf.FeatureCollection().toJson();

    await mapLibreController.addGeoJsonSource(CampaignConstants.routesSourceName, data);

    await mapLibreController.addLineLayer(
      CampaignConstants.routesSourceName,
      CampaignConstants.routesLineLayerId,
      LineLayerProperties(lineJoin: 'round', lineCap: 'round', lineColor: '#FF0000', lineWidth: 7, lineOpacity: 0.6),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    // add selected map layers
    await mapLibreController.addGeoJsonSource(
      CampaignConstants.routesSelectedSourceName,
      turf.FeatureCollection().toJson(),
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.routesSelectedSourceName,
      CampaignConstants.routesLineSelectedLayerId,
      LineLayerProperties(lineJoin: 'round', lineCap: 'round', lineColor: '#FF0000', lineWidth: 7, lineOpacity: 1),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );
  }

  void onRouteLayerStateChanged(bool state, MapInfo mapInfo) async {
    routesVisible = state;
    if (routesVisible) {
      loadRouteLayer(mapInfo);
      showInfoToast(
        t.campaigns.infoToast.routes_activated,
        moreInfoCallback: () => showAboutInfoBox(
          mapInfo.context,
          t.campaigns.infoToast.routes_aboutTitle,
          t.campaigns.infoToast.routes_aboutText,
        ),
      );
    } else {
      mapInfo.mapController.removeLayerSource(CampaignConstants.routesSourceName);
      mapInfo.mapController.removeLayerSource(CampaignConstants.routesSelectedSourceName);
      showInfoToast(t.campaigns.infoToast.routes_deactivated);
    }
  }

  void loadRouteLayer(MapInfo mapInfo) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final routes = await campaignService.loadRoutesInRegion(bbox.southwest, bbox.northeast);
      mapInfo.mapController.setLayerSourceWithFeatureCollection(
        CampaignConstants.routesSourceName,
        routes.transformToFeatureCollection(),
      );
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }
}
