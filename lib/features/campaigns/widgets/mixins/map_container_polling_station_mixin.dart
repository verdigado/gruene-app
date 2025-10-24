part of '../mixins.dart';

mixin MapConsumerPollingStationMixin {
  void removeLayerSource(String layerSourceId);
  Future<void> moveMapIfItemIsOnBorder(LatLng itemCoordinate, Size desiredSize);

  Future<void> onPollingStationClick(
    dynamic feature,
    BuildContext Function() getContext,
    OnShowBottomDetailSheet showBottomDetailSheet,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    var pollingStationFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    setFocusToPollingStation(pollingStationFeature.toJson(), setFocusMode, getMapController);
    var pollingStationDetail = getPollingStationDetailWidget(pollingStationFeature, getContext());
    await showBottomDetailSheet<bool>(pollingStationDetail);
    await unsetFocusToPollingStation(setFocusMode, getMapController);
  }

  Future<void> setFocusToPollingStation(
    Map<String, dynamic> feature,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    // removes the add_marker
    setFocusMode(true);
    // align map to show feature in center area
    final coord = MapHelper.extractLatLngFromFeature(feature);
    await moveMapIfItemIsOnBorder(coord, Size(150, 150));
    // set opacity of marker layer
    await getMapController()!.setLayerProperties(
      CampaignConstants.pollingStationSymbolLayerId,
      SymbolLayerProperties(iconOpacity: 0.2),
    );
    // set data for '_selected layer'
    var featureObject = turf.Feature<turf.Point>.fromJson(feature);
    turf.FeatureCollection collection = turf.FeatureCollection(features: [featureObject]);
    await getMapController()!.setGeoJsonSource(CampaignConstants.pollingStationSelectedSourceName, collection.toJson());
  }

  Future<void> unsetFocusToPollingStation(
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    setFocusMode(false);

    await getMapController()!.setLayerProperties(
      CampaignConstants.pollingStationSymbolLayerId,
      SymbolLayerProperties(iconOpacity: 1),
    );
    removeLayerSource(CampaignConstants.pollingStationSelectedSourceName);
  }

  SizedBox getPollingStationDetailWidget(turf.Feature pollingStationFeature, BuildContext context) {
    onClose() => Navigator.maybePop(context);
    var theme = Theme.of(context);

    return SizedBox(
      height: 278,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: CloseEditWidget(onClose: () => onClose()),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        t.campaigns.pollingStation.label,
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: ThemeColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        height: 95,
                        child: Text(
                          pollingStationFeature.properties!['description'].toString(),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      height: 32,
                      child: TextButton(
                        onPressed: () => openUrl(grueneAppFeedbackUrl, context),
                        child: Text(
                          t.campaigns.pollingStation.reportCorrection,
                          textAlign: TextAlign.right,

                          style: theme.textTheme.labelLarge?.apply(
                            color: ThemeColors.textDark,
                            decoration: TextDecoration.underline,
                            fontWeightDelta: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: ThemeColors.sun,
            padding: EdgeInsets.all(12),
            child: SizedBox(
              height: 56,
              child: Stack(
                children: [
                  Align(alignment: Alignment.topLeft, child: Icon(Icons.info_outlined, size: 24)),
                  Positioned.fill(
                    left: 32,
                    top: 0,
                    bottom: 0,
                    child: Text(t.campaigns.pollingStation.hint, softWrap: true, style: theme.textTheme.labelSmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
