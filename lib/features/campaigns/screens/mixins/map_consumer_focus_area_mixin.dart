part of '../mixins.dart';

mixin MapConsumerFocusAreaMixin on InfoBox {
  bool focusAreasVisible = false;
  GrueneApiCampaignsPoiBaseService get campaignService;
  void hideCurrentSnackBar();
  void showInfoToast(String toastText, {void Function()? moreInfoCallback});

  Future<void> addFocusAreaLayers(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final data = <FocusArea>[].toList().transformToFeatureList().asFeatureCollection().toJson();
    await mapLibreController.addGeoJsonSource(CampaignConstants.focusAreaSourceName, data);

    await mapLibreController.addFillLayer(
      CampaignConstants.focusAreaSourceName,
      CampaignConstants.focusAreaFillLayerId,
      FillLayerProperties(
        fillColor: [
          Expressions.interpolate,
          ['exponential', 0.5],
          [Expressions.zoom],
          18,
          ['get', 'score_color'],
        ],
        fillOpacity: ['get', 'score_opacity'],
      ),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
      belowLayerId: CampaignConstants.markerLayerId,
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.focusAreaSourceName,
      CampaignConstants.focusAreaBorderLayerId,
      LineLayerProperties(lineColor: ThemeColors.background.toHexStringRGB(), lineWidth: 1),
      minzoom: mapInfo.minZoom,
      enableInteraction: false,
    );
  }

  void onFocusAreaLayerStateChanged(bool state, MapInfo mapInfo) async {
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
      mapInfo.mapController.removeLayerSource(CampaignConstants.focusAreaSourceName);
      hideCurrentSnackBar();
      showInfoToast(t.campaigns.infoToast.focusAreas_deactivated);
    }
  }

  void loadFocusAreaLayer(MapInfo mapInfo) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final focusAreas = await campaignService.loadFocusAreasInRegion(bbox.southwest, bbox.northeast);
      mapInfo.mapController.setLayerSourceWithFeatureList(
        CampaignConstants.focusAreaSourceName,
        focusAreas.transformToFeatureList(),
      );
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }
}
