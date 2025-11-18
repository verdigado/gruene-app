part of '../mixins.dart';

mixin MapConsumerRouteMixin on InfoBox {
  bool routesVisible = false;
  GrueneApiCampaignsPoiBaseService get campaignService;
  void hideCurrentSnackBar();
  void showInfoToast(String toastText, {void Function()? moreInfoCallback});

  Future<void> addRouteLayer(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final data = <turf.Feature>{}.toList();

    mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.routesSourceName, data);

    await mapLibreController.addLineLayer(
      CampaignConstants.routesSourceName,
      CampaignConstants.routesLineLayerId,
      LineLayerProperties(lineJoin: 'round', lineCap: 'round', lineColor: '#008939', lineWidth: 7, lineOpacity: 0.7),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    // add selected map layers
    mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.routesSelectedSourceName, data);

    await mapLibreController.addLineLayer(
      CampaignConstants.routesSelectedSourceName,
      CampaignConstants.routesLineSelectedLayerId,
      LineLayerProperties(lineJoin: 'round', lineCap: 'round', lineColor: '#008939', lineWidth: 7, lineOpacity: 1),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );
  }

  void onRouteLayerStateChanged(bool state, MapInfo mapInfo) async {
    routesVisible = state;
    if (routesVisible) {
      loadRouteLayer(mapInfo, true);
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

  void loadRouteLayer(MapInfo mapInfo, bool loadCached) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      if (loadCached) _loadCachedRoutes(mapInfo.loadCachedLayer);

      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final routes = await campaignService.loadRoutesInRegion(bbox.southwest, bbox.northeast);
      mapInfo.mapController.setLayerSourceWithFeatureList(
        CampaignConstants.routesSourceName,
        routes.transformToFeatureList(),
      );
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }

  void _loadCachedRoutes(LoadCachedLayerCallback loadCachedLayer) {
    loadCachedLayer(PoiCacheType.route, CampaignConstants.routesSourceName);
  }
}
