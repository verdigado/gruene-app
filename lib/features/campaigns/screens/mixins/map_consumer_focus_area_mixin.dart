part of '../mixins.dart';

mixin MapConsumerFocusAreaMixin on InfoBox {
  bool focusAreasVisible = false;
  GrueneApiCampaignsPoiBaseService get campaignService;
  void hideCurrentSnackBar();
  void showInfoToast(String toastText, {void Function()? moreInfoCallback});

  Future<void> addFocusAreaLayers(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final data = <turf.Feature>{}.toList();
    await mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.focusAreaSourceName, data);

    await mapLibreController.addFillLayer(
      CampaignConstants.focusAreaSourceName,
      CampaignConstants.focusAreaFillLayerId,
      FillLayerProperties(
        fillColor: [
          Expressions.interpolate,
          ['exponential', 0.5],
          [Expressions.zoom],
          18,
          ['get', CampaignConstants.focusAreaMapScoreColorProperty],
        ],
        fillOpacity: ['get', CampaignConstants.focusAreaMapScoreOpacityProperty],
      ),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
      belowLayerId: CampaignConstants.markerLayerId,
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.focusAreaSourceName,
      CampaignConstants.focusAreaBorderLayerId,
      LineLayerProperties(lineColor: ThemeColors.background.toHexStringRGB(), lineWidth: 0.5, lineOpacity: 0.8),
      minzoom: mapInfo.minZoom,
      enableInteraction: false,
    );

    // add selected map layers
    await mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.focusAreaSelectedSourceName, data);

    await mapLibreController.addLineLayer(
      CampaignConstants.focusAreaSelectedSourceName,
      CampaignConstants.focusAreaLineSelectedLayerId,
      LineLayerProperties(lineColor: 'white', lineWidth: 2),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );
  }

  void onFocusAreaLayerStateChanged(bool state, MapInfo mapInfo) async {
    if (focusAreasVisible == state) return;
    focusAreasVisible = state;
    if (focusAreasVisible) {
      loadFocusAreaLayer(mapInfo);
      showInfoToast(
        t.campaigns.infoToast.focusAreas_activated,
        moreInfoCallback: () => showAboutInfoBox(
          mapInfo.context,
          t.campaigns.infoToast.focusAreas_aboutTitle,
          t.campaigns.infoToast.focusAreas_aboutText,
        ),
      );
    } else {
      await mapInfo.mapController.removeLayerSource(CampaignConstants.focusAreaSourceName);
      await mapInfo.mapController.removeLayerSource(CampaignConstants.focusAreaSelectedSourceName);
      hideCurrentSnackBar();
      showInfoToast(t.campaigns.infoToast.focusAreas_deactivated);
    }
  }

  void loadFocusAreaLayer(MapInfo mapInfo) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final focusAreas = await campaignService.loadFocusAreasInRegion(bbox.southwest, bbox.northeast);
      await mapInfo.mapController.setLayerSourceWithFeatureList(
        CampaignConstants.focusAreaSourceName,
        focusAreas.transformToFeatureList(),
      );
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }
}
