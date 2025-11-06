part of '../mixins.dart';

mixin MapConsumerRouteMixin {
  void removeLayerSource(String layerSourceId);

  Future<void> onRouteClick(
    dynamic feature,
    OnShowBottomDetailSheet showBottomDetailSheet,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    var routeFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    await setFocusToRoute(routeFeature.toJson(), setFocusMode, getMapController);
    var routeDetail = await getRouteDetailWidget(routeFeature);
    await showBottomDetailSheet<bool>(routeDetail);
    await unsetFocusToRoute(setFocusMode, getMapController);
  }

  Future<void> setFocusToRoute(
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

  Future<void> unsetFocusToRoute(
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

  Future<Widget> getRouteDetailWidget(turf.Feature routeFeature) async {
    var routeService = GetIt.I<GrueneApiRouteService>();
    var route = await routeService.getRoute(routeFeature.id.toString());

    return RouteDetail(routeDetail: route.asRouteDetail());
  }
}
