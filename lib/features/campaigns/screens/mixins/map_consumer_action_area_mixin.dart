part of '../mixins.dart';

mixin MapConsumerActionAreaMixin on InfoBox {
  bool actionAreasVisible = true;
  GrueneApiCampaignsPoiBaseService get campaignService;

  Future<void> addActionAreaLayer(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final data = turf.FeatureCollection().toJson();

    addImageFromAsset(
      mapLibreController,
      CampaignConstants.actionAreaSourceName,
      CampaignConstants.actionAreaFillPatternAssetName,
    );

    await mapLibreController.addGeoJsonSource(CampaignConstants.actionAreaSourceName, data);

    await mapLibreController.addFillLayer(
      CampaignConstants.actionAreaSourceName,
      CampaignConstants.actionAreaLayerId,
      FillLayerProperties(
        fillPattern: [Expressions.image, CampaignConstants.actionAreaSourceName],
        fillOpacity: [
          Expressions.match,
          [Expressions.get, 'status'],
          'open',
          1,
          'closed',
          0.3,
          1,
        ],
      ),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.actionAreaSourceName,
      CampaignConstants.actionAreaOutlineLayerId,
      LineLayerProperties(lineColor: 'white', lineWidth: 0.5, lineOpacity: 0.8),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    // set layer properties for selected layer
    await mapLibreController.addGeoJsonSource(CampaignConstants.actionAreaSelectedSourceName, data);

    await mapLibreController.addLineLayer(
      CampaignConstants.actionAreaSelectedSourceName,
      CampaignConstants.actionAreaSelectedOutlineLayerId,
      LineLayerProperties(lineColor: 'white', lineWidth: 2),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );
  }

  void onActionAreaLayerStateChanged(bool state, MapInfo mapInfo) async {
    actionAreasVisible = state;
    if (actionAreasVisible) {
      loadActionAreaLayer(mapInfo);
    } else {
      mapInfo.mapController.removeLayerSource(CampaignConstants.actionAreaSourceName);
    }
  }

  void loadActionAreaLayer(MapInfo mapInfo) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final areas = await campaignService.loadActionAreasInRegion(bbox.southwest, bbox.northeast);
      mapInfo.mapController.setLayerSourceWithFeatureList(
        CampaignConstants.actionAreaSourceName,
        areas.transformToFeatureList(),
      );
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }
}
