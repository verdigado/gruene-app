part of '../mixins.dart';

mixin MapConsumerActionAreaMixin on InfoBox {
  bool actionAreasVisible = true;
  GrueneApiCampaignsPoiBaseService get campaignService;

  Future<void> addActionAreaLayer(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final data = <turf.Feature>{}.toList();

    addImageFromAsset(
      mapLibreController,
      CampaignConstants.actionAreaFillAssetId,
      CampaignConstants.actionAreaFillPatternAssetName,
    );

    mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.actionAreaSourceName, data);

    await mapLibreController.addFillLayer(
      CampaignConstants.actionAreaSourceName,
      CampaignConstants.actionAreaLayerId,
      FillLayerProperties(
        fillPattern: [Expressions.image, CampaignConstants.actionAreaFillAssetId],
        fillOpacity: [
          Expressions.match,
          [Expressions.get, CampaignConstants.featurePropertyStatus],
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

    // assignment symbols
    addImageFromAsset(
      mapLibreController,
      CampaignConstants.actionAreaAssignmentAssetId,
      CampaignConstants.actionAreaAssignemntAssetName,
    );
    await mapLibreController.addSymbolLayer(
      CampaignConstants.actionAreaSourceName,
      CampaignConstants.actionAreaSymbolLayerId,
      SymbolLayerProperties(
        iconImage: CampaignConstants.actionAreaAssignmentAssetId,
        iconSize: [
          Expressions.interpolate,
          ['linear'],
          [Expressions.zoom],
          12,
          1,
          14,
          2.5,
        ],
      ),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
      filter: ['==', CampaignConstants.featurePropertyIsAssigned, true],
    );

    // set layer properties for selected layer
    mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.actionAreaSelectedSourceName, data);

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
      loadActionAreaLayer(mapInfo, true);
    } else {
      mapInfo.mapController.removeLayerSource(CampaignConstants.actionAreaSourceName);
    }
  }

  void loadActionAreaLayer(MapInfo mapInfo, bool loadCached) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      if (loadCached) _loadCachedActionAreas(mapInfo.loadCachedLayer);
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

  void _loadCachedActionAreas(LoadCachedLayerCallback loadCachedLayer) {
    loadCachedLayer(PoiCacheType.actionArea, CampaignConstants.actionAreaSourceName);
  }
}
