part of '../mixins.dart';

mixin MapConsumerPollingStationMixin {
  bool pollingStationVisible = false;
  GrueneApiCampaignsPoiBaseService get campaignService;
  void hideCurrentSnackBar();
  void showInfoToast(String toastText, {void Function()? moreInfoCallback});

  Future<void> addPollingStationLayer(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final initData = <turf.Feature>{}.toList();
    addImageFromAsset(
      mapLibreController,
      CampaignConstants.pollingStationSourceName,
      CampaignConstants.pollingStationAssetName,
    );

    await mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.pollingStationSourceName, initData);

    await mapLibreController.addSymbolLayer(
      CampaignConstants.pollingStationSourceName,
      CampaignConstants.pollingStationSymbolLayerId,
      SymbolLayerProperties(
        iconImage: CampaignConstants.pollingStationSourceName,
        iconSize: [
          Expressions.interpolate,
          ['linear'],
          [Expressions.zoom],
          11,
          1,
          16,
          2,
        ],
        iconAllowOverlap: true,
      ),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    // add selected map layers
    await mapInfo.mapController.setLayerSourceWithFeatureList(
      CampaignConstants.pollingStationSelectedSourceName,
      initData,
    );

    await mapLibreController.addSymbolLayer(
      CampaignConstants.pollingStationSelectedSourceName,
      CampaignConstants.pollingStationSymbolSelectedLayerId,
      const SymbolLayerProperties(
        iconImage: CampaignConstants.pollingStationSourceName,
        iconSize: 3,
        iconAllowOverlap: true,
      ),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );
  }

  void onPollingStationLayerStateChanged(bool state, MapInfo mapInfo) async {
    pollingStationVisible = state;
    if (pollingStationVisible) {
      loadPollingStationLayer(mapInfo);
    } else {
      await mapInfo.mapController.removeLayerSource(CampaignConstants.pollingStationSourceName);
      await mapInfo.mapController.removeLayerSource(CampaignConstants.pollingStationSelectedSourceName);
    }
  }

  void loadPollingStationLayer(MapInfo mapInfo) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final pollingStations = await campaignService.loadPollingStationsInRegion(bbox.southwest, bbox.northeast);
      await mapInfo.mapController.setLayerSourceWithFeatureList(
        CampaignConstants.pollingStationSourceName,
        pollingStations.transformToFeatureList(),
      );
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }
}
