part of '../mixins.dart';

mixin MapConsumerRouteMixin {
  void removeLayerSource(String layerSourceId);

  Future<void> onRouteClick(
    dynamic feature,
    BuildContext Function() getContext,
    OnShowBottomDetailSheet showBottomDetailSheet,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    var routeFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    await setFocusToRoute(routeFeature.toJson(), setFocusMode, getMapController);
    var routeDetail = await getRouteDetailWidget(routeFeature, getContext());
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
      LineLayerProperties(lineOpacity: 0.6),
    );
    removeLayerSource(CampaignConstants.routesSelectedSourceName);
  }

  Future<Widget> getRouteDetailWidget(turf.Feature routeFeature, BuildContext context) async {
    var theme = Theme.of(context);
    var routeService = GetIt.I<GrueneApiRouteService>();
    var route = await routeService.getRoute(routeFeature.id.toString());

    onClose() => Navigator.maybePop(context);

    return SizedBox(
      height: 157,
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
                        '${t.campaigns.route.label} #${route.id}',
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
                      Text(
                        '${t.campaigns.route.routeType_label}: ${route.type.getAsLabel()}',
                        style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.route.createdAt}: ${route.createdAt.getAsLocalDateString()}',
                        style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Switch(value: route.status == RouteStatus.closed, onChanged: (state) => _changeRouteStatus(route, state)),
            ],
          ),
        ],
      ),
    );
  }

  void _changeRouteStatus(Route route, bool state) {
    if (state) {
      // route.status = RouteStatus.closed;
    } else {}
    // api
  }
}
