part of '../mixins.dart';

mixin MapConsumerPollingStationMixin {
  bool pollingStationVisible = false;
  final List<CircleDefinition> _pollingStationCircleDistances = [
    CircleDefinition(distance: 10, color: ThemeColors.himmel600),
    CircleDefinition(distance: 20, color: ThemeColors.himmel600),
    CircleDefinition(distance: 30, color: ThemeColors.himmel600, opacity: 0.3, withLabels: false),
  ];

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
    addImageFromAsset(
      mapLibreController,
      CampaignConstants.pollingStationShieldAssetId,
      CampaignConstants.pollingStationShieldAssetName,
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

    for (var circleDistance in _pollingStationCircleDistances) {
      await mapInfo.mapController.setLayerSourceWithFeatureList(circleDistance.getSourceName(), initData);

      await mapLibreController.addLineLayer(
        circleDistance.getSourceName(),
        circleDistance.getCircleLayerName(),
        LineLayerProperties(
          lineColor: circleDistance.color.toHexStringRGB(),
          lineWidth: 1,
          lineDasharray: [5, 5],
          lineOpacity: circleDistance.opacity,
        ),
        minzoom: mapInfo.minZoom,
        enableInteraction: false,
      );

      if (circleDistance.withLabels) {
        await mapLibreController.addSymbolLayer(
          circleDistance.getSourceName(),
          circleDistance.getCircleSymbolLayerName(),
          SymbolLayerProperties(
            textField: '${circleDistance.distance}m',
            textFont: ['Roboto Regular'],
            textSize: '8',
            textColor: 'white',
            symbolPlacement: 'line',
            iconImage: CampaignConstants.pollingStationShieldAssetId,
            iconSize: 2.5,
            iconRotationAlignment: 'viewport',
            textRotationAlignment: 'viewport',
            symbolSpacing: 1000,
          ),
          minzoom: mapInfo.minZoom,
          enableInteraction: false,
        );
      }
    }

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
    if (pollingStationVisible == state) return;
    pollingStationVisible = state;
    if (pollingStationVisible) {
      loadPollingStationLayer(mapInfo);
    } else {
      await mapInfo.mapController.removeLayerSource(CampaignConstants.pollingStationSourceName);
      await mapInfo.mapController.removeLayerSource(CampaignConstants.pollingStationSelectedSourceName);

      for (var circleDistance in _pollingStationCircleDistances) {
        await mapInfo.mapController.removeLayerSource(circleDistance.getSourceName());
      }
    }
  }

  void loadPollingStationLayer(MapInfo mapInfo) async {
    if (mapInfo.mapController.getCurrentZoomLevel() > mapInfo.minZoom) {
      final bbox = await mapInfo.mapController.getCurrentBoundingBox();

      final pollingStations = await campaignService.loadPollingStationsInRegion(
        mapInfo.campaignId,
        bbox.southwest,
        bbox.northeast,
      );
      var allPollingStationFeatures = pollingStations.transformToFeatureList();
      await mapInfo.mapController.setLayerSourceWithFeatureList(
        CampaignConstants.pollingStationSourceName,
        allPollingStationFeatures,
      );

      for (var circleDistance in _pollingStationCircleDistances) {
        var circleFeatures = allPollingStationFeatures.map((feature) {
          var properties = feature.properties ?? <String, dynamic>{};
          return circle(
            GeoJSONObject.fromJson(feature.geometry!.toJson()),
            circleDistance.distance,
            steps: circleDistance.distance * 4,
            unit: turf.Unit.meters,
            properties: properties,
          );
        }).toList();
        mapInfo.mapController.setLayerSourceWithFeatureList(circleDistance.getSourceName(), circleFeatures);
      }
    } else {
      mapInfo.lastInfoSnackbar?.close();
    }
  }
}

class CircleDefinition {
  final int distance;
  final Color color;
  final double opacity;
  final bool withLabels;

  CircleDefinition({required this.distance, required this.color, this.opacity = 1.0, this.withLabels = true});
}

extension on CircleDefinition {
  String getSourceName() => '${CampaignConstants.pollingStationSourceName}_circle$distance';
  String getCircleLayerName() => '${CampaignConstants.pollingStationSourceName}_circle${distance}_Layer';
  String getCircleSymbolLayerName() => '${CampaignConstants.pollingStationSourceName}_circle${distance}_SymbolLayer';
}
