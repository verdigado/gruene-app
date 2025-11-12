part of '../mixins.dart';

mixin MapContainerActionAreaMixin {
  void removeLayerSource(String layerSourceId);

  Future<void> onActionAreaClick(
    dynamic feature,
    OnShowBottomDetailSheet showBottomDetailSheet,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapLibreMapController,
    MapController Function() getMapController,
  ) async {
    var actionAreaFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    await setFocusToActionArea(actionAreaFeature.toJson(), setFocusMode, getMapLibreMapController);
    var actionAreaDetail = await getActionAreaDetailWidget(actionAreaFeature, getMapController());
    await showBottomDetailSheet<bool>(actionAreaDetail);
    await unsetFocusToActionArea(setFocusMode, getMapLibreMapController);
  }

  Future<void> setFocusToActionArea(
    Map<String, dynamic> feature,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    // removes the add_marker
    setFocusMode(true);

    // align map to show feature in center area
    // TODO determine boundary of area and move map
    // final coord = MapHelper.extractLatLngFromFeature(feature);
    // await moveMapIfItemIsOnBorder(coord, Size(150, 150));

    // set data for '_selected layer'
    var featureObject = turf.Feature<turf.Polygon>.fromJson(feature);
    turf.FeatureCollection collection = turf.FeatureCollection(features: [featureObject]);
    await getMapController()!.setGeoJsonSource(CampaignConstants.actionAreaSelectedSourceName, collection.toJson());
  }

  Future<void> unsetFocusToActionArea(
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    setFocusMode(false);

    removeLayerSource(CampaignConstants.actionAreaSelectedSourceName);
  }

  Future<Widget> getActionAreaDetailWidget(turf.Feature actionAreaFeature, MapController mapController) async {
    var actionAreaService = GetIt.I<GrueneApiActionAreaService>();
    var actionArea = await actionAreaService.getActionArea(actionAreaFeature.id.toString());

    return ActionAreaDetail(actionAreaDetail: actionArea.asActionAreaDetail(), mapController: mapController);
  }
}
