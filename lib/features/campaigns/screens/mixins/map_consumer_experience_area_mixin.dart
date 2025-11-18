part of '../mixins.dart';

mixin MapConsumerExperienceAreaMixin {
  bool experienceAreasVisible = false;
  GrueneApiCampaignsPoiBaseService get campaignService;

  Future<void> addExperienceAreaLayer(MapLibreMapController mapLibreController, MapInfo mapInfo) async {
    final data = <turf.Feature>{}.toList();

    addImageFromAsset(
      mapLibreController,
      CampaignConstants.experienceAreaSourceName,
      CampaignConstants.experienceAreaFillPatternAssetName,
    );

    mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.experienceAreaSourceName, data);

    await mapLibreController.addFillLayer(
      CampaignConstants.experienceAreaSourceName,
      CampaignConstants.experienceAreaLayerId,
      FillLayerProperties(
        fillPattern: [Expressions.image, CampaignConstants.experienceAreaSourceName],
        fillOpacity: 0.8,
      ),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.experienceAreaSourceName,
      CampaignConstants.experienceAreaOutlineLayerId,
      LineLayerProperties(lineColor: 'white', lineWidth: 0.3, lineOpacity: 0.8),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    // add selected map layers
    mapInfo.mapController.setLayerSourceWithFeatureList(CampaignConstants.experienceAreaSelectedSourceName, data);

    await mapLibreController.addFillLayer(
      CampaignConstants.experienceAreaSelectedSourceName,
      CampaignConstants.experienceAreaSelectedLayerId,
      FillLayerProperties(fillPattern: [Expressions.image, CampaignConstants.experienceAreaSourceName]),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.experienceAreaSelectedSourceName,
      CampaignConstants.experienceAreaSelectedOutlineLayerId,
      LineLayerProperties(lineColor: 'white', lineWidth: 2),
      enableInteraction: false,
      minzoom: mapInfo.minZoom,
    );
  }

  void onExperienceAreaLayerStateChanged(bool state, MapInfo mapInfo) {
    experienceAreasVisible = state;
    if (experienceAreasVisible) {
      loadExperienceAreaLayer(mapInfo);
    } else {
      mapInfo.mapController.removeLayerSource(CampaignConstants.experienceAreaSourceName);
      mapInfo.mapController.removeLayerSource(CampaignConstants.experienceAreaSelectedSourceName);
    }
  }

  void loadExperienceAreaLayer(MapInfo mapInfo) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final experienceAreas = await campaignService.loadExperienceAreasInRegion(bbox.southwest, bbox.northeast);
      mapInfo.mapController.setLayerSourceWithFeatureList(
        CampaignConstants.experienceAreaSourceName,
        experienceAreas.transformToFeatureList(),
      );
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }

  void loadCachedActionAreas(LoadCachedLayerCallback loadCachedLayer) {
    loadCachedLayer(PoiCacheType.actionArea, CampaignConstants.actionAreaSourceName);
  }
}
