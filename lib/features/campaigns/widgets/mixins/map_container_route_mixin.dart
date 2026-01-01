part of '../mixins.dart';

mixin MapContainerRouteMixin {
  void removeLayerSource(String layerSourceId);

  Future<void> onRouteClick(
    dynamic feature,
    OnShowBottomDetailSheet showBottomDetailSheet,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapLibreMapController,
    MapController Function() getMapController,
  ) async {
    var routeFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    await _setFocusToRoute(routeFeature.toJson(), setFocusMode, getMapLibreMapController);
    var routeDetail = await _getRouteDetailWidget(routeFeature, getMapController());
    await showBottomDetailSheet<bool>(routeDetail);
    await _unsetFocusToRoute(setFocusMode, getMapLibreMapController);
  }

  Future<void> _setFocusToRoute(
    Map<String, dynamic> feature,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    // removes the add_marker
    setFocusMode(true);

    // align map to show feature in center area
    // TODO determine boundary of line and move map
    // final coord = MapHelper.extractLatLngFromFeature(feature);
    // await moveMapIfItemIsOnBorder(coord, Size(150, 150));

    // set opacity of marker layer
    await getMapController()!.setLayerProperties(
      CampaignConstants.routesLineLayerId,
      LineLayerProperties(lineOpacity: 0.3),
    );
    // set data for '_selected layer'
    var featureObject = turf.Feature<turf.LineString>.fromJson(feature);
    turf.FeatureCollection collection = turf.FeatureCollection(features: [featureObject]);
    await getMapController()!.setGeoJsonSource(CampaignConstants.routesSelectedSourceName, collection.toJson());
  }

  Future<void> _unsetFocusToRoute(
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    setFocusMode(false);

    await getMapController()!.setLayerProperties(
      CampaignConstants.routesLineLayerId,
      LineLayerProperties(lineOpacity: 0.7),
    );
    removeLayerSource(CampaignConstants.routesSelectedSourceName);
  }

  Future<Widget> _getRouteDetailWidget(turf.Feature routeFeature, MapController mapController) async {
    final isCached = MapHelper.extractIsCachedFromFeature(routeFeature.toJson());
    var getFromCacheOrApi = isCached ? _getCachedRoute : _getRoute;

    return RouteDetail(routeDetail: await getFromCacheOrApi(routeFeature.id.toString()), mapController: mapController);
  }

  Future<RouteDetailModel> _getRoute(String routeId) async {
    var routeService = GetIt.I<GrueneApiRouteService>();
    return (await routeService.getRoute(routeId)).asRouteDetail();
  }

  Future<RouteDetailModel> _getCachedRoute(String routeId) {
    return GetIt.I<CampaignActionCache>().getLatestRouteDetail(routeId);
  }
}
