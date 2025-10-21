import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_experience_area_service.dart';
import 'package:gruene_app/app/services/gruene_api_route_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/features/campaigns/helper/app_settings.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/helper/marker_item_helper.dart';
import 'package:gruene_app/features/campaigns/helper/marker_item_manager.dart';
import 'package:gruene_app/features/campaigns/helper/util.dart';
import 'package:gruene_app/features/campaigns/location/determine_position.dart';
import 'package:gruene_app/features/campaigns/models/bounding_box.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/widgets/attribution_dialog.dart';
import 'package:gruene_app/features/campaigns/widgets/close_edit_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/location_button.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller_simplified.dart';
import 'package:gruene_app/features/campaigns/widgets/mixins.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/turf.dart' as turf;

typedef OnMapCreatedCallback = void Function(MapController controller);
typedef AddPOIClickedCallback = void Function(LatLng location);
typedef LoadVisibleItemsCallBack = void Function(LatLng locationSW, LatLng locationNE);
typedef LoadCachedItemsCallback = void Function();
typedef LoadDataLayersCallBack = void Function(LatLng locationSW, LatLng locationNE);
typedef GetMarkerImagesCallback = Map<String, String> Function();
typedef OnFeatureClickCallback = void Function(dynamic feature);
typedef GetBasicPoiFromFeatureCallback = Future<BasicPoi> Function(Map<String, dynamic> feature);
typedef OnNoFeatureClickCallback = void Function(Point<double> point);
typedef OnShowBottomDetailSheet = Future<U?> Function<U>(Widget detailWidget);
typedef OnEditItemClickedCallback = void Function();
typedef ShowMapInfoAfterCameraMoveCallback = void Function();
typedef AddMapLayersForContextCallback = void Function(MapLibreMapController mapLibreController);

class MapContainer extends StatefulWidget {
  final OnMapCreatedCallback? onMapCreated;
  final AddPOIClickedCallback? addPOIClicked;
  final LoadVisibleItemsCallBack? loadVisibleItems;
  final LoadCachedItemsCallback? loadCachedItems;
  final LoadDataLayersCallBack? loadDataLayers;
  final GetMarkerImagesCallback? getMarkerImages;
  final GetBasicPoiFromFeatureCallback getBasicPoiFromFeature;
  final OnFeatureClickCallback? onFeatureClick;
  final OnNoFeatureClickCallback? onNoFeatureClick;
  final OnShowBottomDetailSheet showBottomDetailSheet;
  final AddMapLayersForContextCallback? addMapLayersForContext;
  final ShowMapInfoAfterCameraMoveCallback? showMapInfoAfterCameraMove;
  final LatLng? userLocation;
  final bool locationAvailable;

  const MapContainer({
    super.key,
    required this.onMapCreated,
    required this.addPOIClicked,
    required this.loadVisibleItems,
    required this.loadCachedItems,
    required this.getMarkerImages,
    required this.onFeatureClick,
    required this.onNoFeatureClick,
    required this.showBottomDetailSheet,
    required this.getBasicPoiFromFeature,
    this.loadDataLayers,
    this.addMapLayersForContext,
    required this.locationAvailable,
    required this.showMapInfoAfterCameraMove,
    this.userLocation,
  });

  @override
  State<StatefulWidget> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer>
    with MapConsumerExperienceAreaMixin
    implements MapController, MapControllerSimplified {
  MapLibreMapController? _controller;
  final MarkerItemManager _markerItemManager = MarkerItemManager();
  final appSettings = GetIt.I<AppSettings>();
  final campaignActionCache = GetIt.I<CampaignActionCache>();

  bool _isMapInitialized = false;
  bool _permissionGiven = false;
  final defaultStartLocation = CampaignConstants.centerGermany;

  static const minZoomMarkerItems = 11.5;
  static const double zoomLevelUserLocation = 16;
  static const double multiSelectZoomThreshold = 16.5;
  static const double zoomLevelSearchLocation = 14.5;
  static const double zoomLevelUserOverview = 5.2;

  List<Widget> popups = [];
  List<Widget> infos = [];

  final _cameraTargetBounds = CampaignConstants.viewBoxGermany;

  var followUserLocation = true;

  bool _showAddMarker = true;

  bool _isInFocusMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _permissionGiven = widget.locationAvailable;
  }

  @override
  Widget build(BuildContext context) {
    const mapLibreColor = Color(0xFF979897);

    final userLocation = appSettings.campaign.lastPosition ?? widget.userLocation;
    final cameraPosition = userLocation != null
        ? CameraPosition(target: userLocation, zoom: (appSettings.campaign.lastZoomLevel ?? zoomLevelUserLocation))
        : CameraPosition(target: defaultStartLocation, zoom: zoomLevelUserOverview);

    Widget addMarker = SizedBox(height: 0, width: 0);
    if (popups.isEmpty && _showAddMarker & !_isInFocusMode) {
      addMarker = Center(
        child: Container(
          padding: EdgeInsets.only(bottom: 65 /* height of the add_marker icon to position it exactly on the middle */),
          child: GestureDetector(onTap: _onIconTap, child: SvgPicture.asset(CampaignConstants.addMarkerAssetName)),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: Config.maplibreUrl,
            onMapCreated: _onMapCreated,
            attributionButtonMargins: const Point(-100, -100),
            logoViewMargins: const Point(double.maxFinite, double.maxFinite),

            initialCameraPosition: cameraPosition,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            cameraTargetBounds: CameraTargetBounds(_cameraTargetBounds),
            trackCameraPosition: true,
            onCameraIdle: _onCameraIdle,
            onMapClick: _onMapClick,
            myLocationEnabled: _permissionGiven,
            // myLocationTrackingMode: _permissionGiven ? MyLocationTrackingMode.Tracking : MyLocationTrackingMode.None,
            myLocationTrackingMode: MyLocationTrackingMode.none,
            myLocationRenderMode: MyLocationRenderMode.normal,
            minMaxZoomPreference: const MinMaxZoomPreference(4.5, 18.0),
          ),
          addMarker,
          Positioned(
            bottom: 12,
            right: 12,
            child: LocationButton(bringCameraToUser: bringCameraToUser, followUserLocation: followUserLocation),
          ),
          Positioned(
            bottom: -8,
            right: -8,
            child: IconButton(
              color: mapLibreColor,
              iconSize: 20,
              icon: const Icon(Icons.info_outlined),
              onPressed: () {
                showDialog<void>(context: context, builder: (context) => const AttributionDialog());
              },
            ),
          ),
          ...popups,
          ...infos,
        ],
      ),
    );
  }

  void _onMapCreated(MapLibreMapController controller) async {
    if (!mounted) return;

    setState(() {
      _controller = controller;
      _isMapInitialized = true;
    });

    final onMapCreated = widget.onMapCreated;
    if (onMapCreated != null) {
      onMapCreated(this);
    }

    campaignActionCache.setCurrentMapController(this);

    _loadDataOnMap(init: true);
  }

  void _loadDataOnMap({bool init = false}) async {
    final visRegion = await _controller?.getVisibleRegion();
    var currentZoomLevel = _controller!.cameraPosition!.zoom;

    debugPrint('Bounding Box: SW-${visRegion!.southwest} NE-${visRegion.northeast}');
    debugPrint('Zoom level: $currentZoomLevel');

    _showAddMarker = currentZoomLevel > minimumMarkerZoomLevel;

    if (init) {
      final loadCachedItems = widget.loadCachedItems;
      if (loadCachedItems != null) loadCachedItems();
    }
    final loadVisibleItems = widget.loadVisibleItems;
    if (loadVisibleItems != null) {
      loadVisibleItems(visRegion.southwest, visRegion.northeast);
    }

    final loadDataLayers = widget.loadDataLayers;
    if (loadDataLayers != null) {
      loadDataLayers(visRegion.southwest, visRegion.northeast);
    }

    final showInfo = widget.showMapInfoAfterCameraMove;
    if (showInfo != null) {
      showInfo();
    }
  }

  void _onIconTap() {
    final addPOIClicked = widget.addPOIClicked;

    if (addPOIClicked != null) {
      addPOIClicked(_controller!.cameraPosition!.target);
    }
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final targetLatLng = await controller.toLatLng(point);
    if (!mounted) return;

    final onFeatureClick = widget.onFeatureClick;
    final onNoFeatureClick = widget.onNoFeatureClick;

    final jsonFeaturesPoiMarkers = await getFeaturesInScreen(point, [CampaignConstants.markerLayerName]);
    final poiMarkers = jsonFeaturesPoiMarkers.map((e) => e as Map<String, dynamic>).toList();

    if (poiMarkers.isNotEmpty && onFeatureClick != null) {
      logger.d('Features: ${poiMarkers.length} Zoom: ${_controller!.cameraPosition!.zoom.toString()}');
      dynamic feature;
      var allPositions = poiMarkers.map(MapHelper.extractLatLngFromFeature).toList();
      var hasDuplicates = allPositions.map((item) => allPositions.where((x) => x == item).length).any((x) => x > 1);

      // Either the list contains position duplicates or the zoom level is high enough so that a user-select makes sense
      if (hasDuplicates || (poiMarkers.length > 1 && _controller!.cameraPosition!.zoom > multiSelectZoomThreshold)) {
        poiMarkers.sort((itemA, itemB) {
          // sort list by distance from tapped map location
          var distanceA = targetLatLng.getDistance(MapHelper.extractLatLngFromFeature(itemA));
          var distanceB = targetLatLng.getDistance(MapHelper.extractLatLngFromFeature(itemB));
          return distanceA.compareTo(distanceB);
        });

        feature = await _userMultiSelect(poiMarkers);
      } else {
        feature = MapHelper.getClosestFeature(poiMarkers, targetLatLng);
      }
      if (feature == null) return;
      onFeatureClick(feature);
      return;
    }

    final jsonFeaturesPollingStations = await getFeaturesInScreen(point, [
      CampaignConstants.pollingStationSymbolLayerId,
    ]);
    final pollingStations = jsonFeaturesPollingStations.map((e) => e as Map<String, dynamic>).toList();

    if (pollingStations.isNotEmpty) {
      final feature = MapHelper.getClosestFeature(pollingStations, targetLatLng);

      onPollingStationClick(feature);
      return;
    }

    final jsonFeaturesRoutes = await getFeaturesInScreen(point, [CampaignConstants.routesLineLayerId]);
    final routes = jsonFeaturesRoutes.map((e) => e as Map<String, dynamic>).toList();

    if (routes.isNotEmpty) {
      final feature = MapHelper.getClosestFeature(routes, targetLatLng);

      onRouteClick(feature);
      return;
    }

    final jsonFeaturesExperienceAreas = await getFeaturesInScreen(point, [CampaignConstants.experienceAreaLayerId]);
    final experienceAreas = jsonFeaturesExperienceAreas.map((e) => e as Map<String, dynamic>).toList();

    if (experienceAreas.isNotEmpty) {
      final feature = MapHelper.getClosestFeature(experienceAreas, targetLatLng);

      onExperienceAreaClick(feature);
      return;
    }

    if (onNoFeatureClick != null) {
      onNoFeatureClick(point);
    }
  }

  @override
  Future<dynamic> getClosestFeaturesInScreen(Point<double> point, List<String> layers) async {
    var features = await getFeaturesInScreen(point, layers);
    if (features.isNotEmpty) {
      final controller = _controller!;
      final targetLatLng = await controller.toLatLng(point);
      return MapHelper.getClosestFeature(features, targetLatLng);
    } else {
      return null;
    }
  }

  @override
  Future<List<dynamic>> getFeaturesInScreen(Point<double> point, List<String> layers) async {
    final controller = _controller!;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final touchTargetSize = pixelRatio * 38.0; // corresponds to 1 cm roughly
    final rect = Rect.fromCenter(center: Offset(point.x, point.y), width: touchTargetSize, height: touchTargetSize);

    final jsonFeatures = await controller.queryRenderedFeaturesInRect(rect, layers, null);
    return jsonFeatures;
  }

  void _onCameraIdle() async {
    if (!_isMapInitialized) return;

    _storeLastCameraPosition();

    _loadDataOnMap();
  }

  void _onStyleLoadedCallback() async {
    if (widget.getMarkerImages != null) {
      widget.getMarkerImages!().forEach((x, y) async {
        await addImageFromAsset(_controller!, x, y);
      });
    }

    await _controller!.addGeoJsonSource(
      CampaignConstants.markerSourceName,
      MarkerItemHelper.transformListToGeoJson(<MarkerItemModel>[]).toJson(),
    );

    await _controller!.addSymbolLayer(
      CampaignConstants.markerSourceName,
      CampaignConstants.markerLayerName,
      const SymbolLayerProperties(
        iconImage: ['get', 'status_type'],
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
      minzoom: minZoomMarkerItems,
      filter: [
        '!',
        ['has', 'point_count'],
      ],
    );

    // add selected map layers
    await _controller!.addGeoJsonSource(
      '${CampaignConstants.markerSourceName}_selected',
      MarkerItemHelper.transformListToGeoJson(<MarkerItemModel>[]).toJson(),
    );

    await _controller!.addSymbolLayer(
      '${CampaignConstants.markerSourceName}_selected',
      '${CampaignConstants.markerLayerName}_selected',
      const SymbolLayerProperties(iconImage: ['get', 'status_type'], iconSize: 3, iconAllowOverlap: true),
      enableInteraction: false,
      minzoom: minZoomMarkerItems,
    );

    // init context layers re-directed to context screens
    widget.addMapLayersForContext!(_controller!);
  }

  @override
  void setMarkerSource(List<MarkerItemModel> poiList) {
    _markerItemManager.addMarkers(poiList);
    _controller!.setGeoJsonSource(
      CampaignConstants.markerSourceName,
      MarkerItemHelper.transformListToGeoJson(_markerItemManager.getMarkers()).toJson(),
    );
  }

  @override
  void setLayerSourceWithFeatureCollection(String sourceId, turf.FeatureCollection layerData) async {
    final sourceIds = await _controller!.getSourceIds();
    if (sourceIds.contains(sourceId)) {
      await _controller!.setGeoJsonSource(sourceId, layerData.toJson());
    } else {
      await _controller!.addGeoJsonSource(sourceId, layerData.toJson());
    }
  }

  @override
  void removeLayerSource(String sourceId) async {
    /* 
    * A bug prevents using correct method -> see https://github.com/maplibre/flutter-maplibre-gl/issues/526
    * Therefore we set it as empty datasource. Once the issue has been corrected we can use the designated method.
    */
    // await _controller!.removeSource(sourceId);
    await _controller!.setGeoJsonSource(sourceId, turf.FeatureCollection().toJson());
  }

  @override
  void addMarkerItem(MarkerItemModel markerItem) {
    setMarkerSource([markerItem]);
  }

  @override
  void removeMarkerItem(int markerItemId) {
    _markerItemManager.removeMarker(markerItemId);
    _controller!.setGeoJsonSource(
      CampaignConstants.markerSourceName,
      MarkerItemHelper.transformListToGeoJson(_markerItemManager.getMarkers()).toJson(),
    );
  }

  @override
  Future<Point<num>> getScreenPointFromLatLng(LatLng coord) async {
    final point = await _controller!.toScreenLocation(coord);
    return point;
  }

  @override
  void showMapPopover(
    LatLng coord,
    Widget widget,
    OnEditItemClickedCallback? onEditItemClicked,
    Size desiredSize,
  ) async {
    if (!mounted) return;

    await moveMapIfItemIsOnBorder(coord, desiredSize);
    final point = await getScreenPointFromLatLng(coord);

    _showPopOver(point, widget, onEditItemClicked, desiredSize: desiredSize);
  }

  @override
  Future<void> setFocusToMarkerItem(Map<String, dynamic> feature) async {
    // removes the add_marker
    setState(() {
      _isInFocusMode = true;
    });
    // align map to show feature in center area
    final coord = MapHelper.extractLatLngFromFeature(feature);
    await moveMapIfItemIsOnBorder(coord, Size(150, 150));
    // set opacity of marker layer
    await _controller!.setLayerProperties(CampaignConstants.markerLayerName, SymbolLayerProperties(iconOpacity: 0.2));
    // set data for '_selected layer'
    var featureObject = turf.Feature<turf.Point>.fromJson(feature);
    turf.FeatureCollection collection = turf.FeatureCollection(features: [featureObject]);
    await _controller!.setGeoJsonSource('${CampaignConstants.markerSourceName}_selected', collection.toJson());
  }

  Future<void> setFocusToPollingStation(Map<String, dynamic> feature) async {
    // removes the add_marker
    setState(() {
      _isInFocusMode = true;
    });
    // align map to show feature in center area
    final coord = MapHelper.extractLatLngFromFeature(feature);
    await moveMapIfItemIsOnBorder(coord, Size(150, 150));
    // set opacity of marker layer
    await _controller!.setLayerProperties(
      CampaignConstants.pollingStationSymbolLayerId,
      SymbolLayerProperties(iconOpacity: 0.2),
    );
    // set data for '_selected layer'
    var featureObject = turf.Feature<turf.Point>.fromJson(feature);
    turf.FeatureCollection collection = turf.FeatureCollection(features: [featureObject]);
    await _controller!.setGeoJsonSource(CampaignConstants.pollingStationSelectedSourceName, collection.toJson());
  }

  Future<void> unsetFocusToPollingStation() async {
    setState(() {
      _isInFocusMode = false;
    });
    await _controller!.setLayerProperties(
      CampaignConstants.pollingStationSymbolLayerId,
      SymbolLayerProperties(iconOpacity: 1),
    );
    removeLayerSource(CampaignConstants.pollingStationSelectedSourceName);
  }

  Future<void> setFocusToRoute(Map<String, dynamic> feature) async {
    // removes the add_marker
    setState(() {
      _isInFocusMode = true;
    });
    // align map to show feature in center area
    // TODO determine boundary of line and move map
    // final coord = MapHelper.extractLatLngFromFeature(feature);
    // await moveMapIfItemIsOnBorder(coord, Size(150, 150));

    // set opacity of marker layer
    await _controller!.setLayerProperties(CampaignConstants.routesLineLayerId, LineLayerProperties(lineOpacity: 0.3));
    // set data for '_selected layer'
    var featureObject = turf.Feature<turf.LineString>.fromJson(feature);
    turf.FeatureCollection collection = turf.FeatureCollection(features: [featureObject]);
    await _controller!.setGeoJsonSource(CampaignConstants.routesSelectedSourceName, collection.toJson());
  }

  Future<void> unsetFocusToRoute() async {
    setState(() {
      _isInFocusMode = false;
    });
    await _controller!.setLayerProperties(CampaignConstants.routesLineLayerId, LineLayerProperties(lineOpacity: 0.6));
    removeLayerSource(CampaignConstants.routesSelectedSourceName);
  }

  @override
  Future<void> unsetFocusToMarkerItem() async {
    setState(() {
      _isInFocusMode = false;
    });
    await _controller!.setLayerProperties(CampaignConstants.markerLayerName, SymbolLayerProperties(iconOpacity: 1));
    await _controller!.setGeoJsonSource(
      '${CampaignConstants.markerSourceName}_selected',
      turf.FeatureCollection<turf.Point>(features: []).toJson(),
    );
  }

  Future<void> moveMapIfItemIsOnBorder(LatLng itemCoordinate, Size desiredSize) async {
    final mediaQuery = MediaQuery.of(context);
    final currentSize = mediaQuery.size;

    final verticalBorderThresholdInPercent = (desiredSize.height / currentSize.height) * 1.9;
    final horizontalBorderThresholdInPercent = (desiredSize.width / currentSize.width) / 2 * 1.1;

    const animationInMilliseconds = 300;
    final centerCoord = _controller!.cameraPosition!.target;
    final visibleRegion = await _controller!.getVisibleRegion();
    final visibleRegionHeight = visibleRegion.northeast.latitude - visibleRegion.southwest.latitude;
    final visibleRegionWidth = visibleRegion.northeast.longitude - visibleRegion.southwest.longitude;

    double? newLatitude;
    double? newLongitude;

    var verticalThresholdDistance = visibleRegionHeight * verticalBorderThresholdInPercent;
    var horizontalThresholdDistance = visibleRegionWidth * horizontalBorderThresholdInPercent;

    // check whether coordinate is in border region (defined as percentage of visible area) of visible area
    if ((visibleRegion.northeast.latitude - verticalThresholdDistance) < itemCoordinate.latitude) {
      final diff = itemCoordinate.latitude - (visibleRegion.northeast.latitude - verticalThresholdDistance);
      newLatitude = centerCoord.latitude + diff + (verticalThresholdDistance * 0.4);
    } else if ((visibleRegion.southwest.latitude + verticalThresholdDistance) > itemCoordinate.latitude) {
      newLatitude = centerCoord.latitude - (verticalThresholdDistance / 2);
    }
    if ((visibleRegion.northeast.longitude - horizontalThresholdDistance) < itemCoordinate.longitude) {
      newLongitude = centerCoord.longitude + horizontalThresholdDistance;
    } else if ((visibleRegion.southwest.longitude + horizontalThresholdDistance) > itemCoordinate.longitude) {
      newLongitude = centerCoord.longitude - horizontalThresholdDistance;
    }

    if (newLongitude != null || newLatitude != null) {
      // find new target and animate camera
      final newTarget = LatLng(newLatitude ?? centerCoord.latitude, newLongitude ?? centerCoord.longitude);
      // ignore: unused_local_variable
      await _controller!.animateCamera(
        CameraUpdate.newLatLng(newTarget),
        duration: Duration(milliseconds: animationInMilliseconds),
      );
    }
  }

  void _showPopOver(
    Point<num> pointOnScreen,
    Widget widget,
    OnEditItemClickedCallback? onEditItemClicked, {
    Size desiredSize = const Size(100, 100),
  }) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    var pixelRatio = Platform.isAndroid ? mediaQuery.devicePixelRatio : 1.0;

    setState(() {
      popups.clear();
      num popupHeight = desiredSize.height - 15;
      num popupWidth = desiredSize.width;
      popups.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(color: ThemeColors.secondary.withAlpha(30)),
          onTap: () {
            setState(() {
              popups.clear();
            });
          },
        ),
      );
      final heightArrowTriangle = 10.0;
      popups.add(
        Positioned(
          top: ((pointOnScreen.y / pixelRatio) - popupHeight).toDouble() - (5 + heightArrowTriangle) - 5,
          left: (pointOnScreen.x / pixelRatio) - (popupWidth / 2),
          child: Column(
            children: [
              Container(
                width: popupWidth.toDouble(),
                height: popupHeight.toDouble() + 5,
                decoration: BoxDecoration(color: ThemeColors.background, borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.only(top: 3, left: 5, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                popups.clear();
                              });
                            },
                            child: Icon(Icons.close_outlined, size: 14),
                          ),
                          GestureDetector(
                            onTap: () => onTapPopup(onEditItemClicked),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 1.5, color: ThemeColors.textDark)),
                              ),
                              child: Text(
                                t.common.actions.edit,
                                style: theme.textTheme.labelSmall?.apply(
                                  color: ThemeColors.textDark,
                                  fontWeightDelta: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onTapPopup(onEditItemClicked),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        width: popupWidth.toDouble(),
                        height: popupHeight.toDouble() - 25,
                        child: widget,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: ClipPath(
                  clipper: MyTriangle(),
                  child: Container(color: ThemeColors.background, width: 15, height: heightArrowTriangle),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void onTapPopup(OnEditItemClickedCallback? onEditItemClicked) {
    if (onEditItemClicked == null) return;
    setState(() {
      popups.clear();
    });
    onEditItemClicked();
  }

  @override
  Future<BoundingBox> getCurrentBoundingBox() async {
    final visRegion = await _controller?.getVisibleRegion();
    return BoundingBox(southwest: visRegion!.southwest, northeast: visRegion.northeast);
  }

  @override
  double getCurrentZoomLevel() {
    return _controller!.cameraPosition!.zoom;
  }

  @override
  double get minimumMarkerZoomLevel => minZoomMarkerItems;

  Future<void> bringCameraToUser(RequestedPosition positionRequest) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final position = positionRequest.position;
    if (position == null) return;

    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        bearing: 0,
        tilt: 0,
        zoom: zoomLevelUserLocation,
      ),
    );
    await controller.animateCamera(cameraUpdate);
    if (!mounted) return;

    // await controller.updateMyLocationTrackingMode(MyLocationTrackingMode.tracking);
    if (!mounted) return;
    if (!_permissionGiven) {
      setState(() => _permissionGiven = true);
    }
  }

  @override
  void toggleInfoForMissingMapFeatures(bool enable) {
    if (enable) {
      if (infos.isNotEmpty) return;
      setState(() {
        final mediaQuery = MediaQuery.of(context);
        final theme = Theme.of(context);
        infos.add(
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    width: mediaQuery.size.width * 0.75,
                    decoration: BoxDecoration(
                      color: ThemeColors.infoBackground.withAlpha(130),
                      border: Border.all(color: ThemeColors.infoBackground, width: 4),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outlined, color: ThemeColors.textCancel, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.campaigns.map.noMapDataInfo,
                            style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textCancel),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
    } else {
      setState(() {
        infos.clear();
      });
    }
  }

  void _storeLastCameraPosition() {
    appSettings.campaign.lastPosition = _controller!.cameraPosition!.target;
    appSettings.campaign.lastZoomLevel = _controller!.cameraPosition!.zoom;
  }

  @override
  void navigateMapTo(LatLng location) async {
    await _controller!.animateCamera(
      CameraUpdate.newLatLngZoom(location, zoomLevelSearchLocation),
      duration: Duration(seconds: 1),
    );
  }

  @override
  void resetMarkerItems() {
    if (!mounted) return;
    _markerItemManager.resetAllMarkers();
    _loadDataOnMap(init: true);
  }

  Future<Map<String, dynamic>?> _userMultiSelect(List<Map<String, dynamic>> features) async {
    var theme = Theme.of(context);

    var selectedFeature = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: ThemeColors.backgroundSecondary,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(t.common.multiSelect(count: features.length), style: theme.textTheme.titleSmall),
                  ),
                  SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 250),
                    child: RawScrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          children: features.map((item) {
                            var itemsOnSamePos = features
                                .map(MapHelper.extractLatLngFromFeature)
                                .where((x) => x == MapHelper.extractLatLngFromFeature(item));
                            var isDuplicate = itemsOnSamePos.length > 1;
                            return _getMultiSelectRow(item, isDuplicate);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    return selectedFeature;
  }

  Widget _getMultiSelectRow(Map<String, dynamic> feature, bool isDuplicate) {
    final markerImages = widget.getMarkerImages!();
    var theme = Theme.of(context);
    return FutureBuilder(
      future: widget.getBasicPoiFromFeature(feature),
      builder: (context, AsyncSnapshot<BasicPoi> snapshot) {
        if (!snapshot.hasData || snapshot.hasError) return Text('...');
        var poi = snapshot.data!;
        return GestureDetector(
          onTap: () => Navigator.maybePop(context, feature),
          child: Card(
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            shadowColor: ThemeColors.textDisabled,
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(6),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      child: SizedBox(
                        height: 20,
                        child: Image.asset(markerImages[MapHelper.extractStatusTypeFromFeature(feature)]!),
                      ),
                    ),
                    Column(
                      children: [
                        if (isDuplicate)
                          Text(t.campaigns.map.identicalPositions, style: TextStyle(color: ThemeColors.textWarning)),
                        Text(
                          '${poi.address.street} ${poi.address.houseNumber}\n${poi.address.zipCode} ${poi.address.city}',
                          style: theme.textTheme.labelMedium!.copyWith(color: ThemeColors.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onPollingStationClick(dynamic feature) async {
    var pollingStationFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    setFocusToPollingStation(pollingStationFeature.toJson());
    var pollingStationDetail = getPollingStationDetailWidget(pollingStationFeature);
    await widget.showBottomDetailSheet<bool>(pollingStationDetail);
    await unsetFocusToPollingStation();
  }

  Future<void> onRouteClick(dynamic feature) async {
    var routeFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    setFocusToRoute(routeFeature.toJson());
    var routeDetail = await getRouteDetailWidget(routeFeature);
    await widget.showBottomDetailSheet<bool>(routeDetail);
    await unsetFocusToRoute();
  }

  Future<void> onExperienceAreaClick(dynamic feature) async {
    var experienceAreaFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    var experienceAreaDetail = await getExperienceAreaDetailWidget(experienceAreaFeature);
    // set data for '_selected layer'
    // var collection = turf.FeatureCollection(features: [experienceAreaFeature]);
    // await _controller!.setGeoJsonSource(CampaignConstants.experienceAreaSelectedSourceName, collection.toJson());
    await setFocusToExperienceArea(feature);

    await widget.showBottomDetailSheet<bool>(experienceAreaDetail);
    await unsetFocusToExperienceArea(feature);
  }

  Future<void> setFocusToExperienceArea(Map<String, dynamic> feature) async {
    // removes the add_marker
    setState(() {
      _isInFocusMode = true;
    });
    // align map to show feature in center area
    // TODO determine boundary of line and move map
    // final coord = MapHelper.extractLatLngFromFeature(feature);
    // await moveMapIfItemIsOnBorder(coord, Size(150, 150));

    // set opacity of marker layer
    await _controller!.setLayerProperties(
      CampaignConstants.experienceAreaLayerId,
      FillLayerProperties(visibility: 'none'),
    );
    await _controller!.setLayerProperties(
      CampaignConstants.experienceAreaOutlineLayerId,
      LineLayerProperties(visibility: 'none'),
    );

    // set data for '_selected layer'
    var featureObject = turf.Feature.fromJson(feature);
    // if (featureObject.properties == null) {
    //   featureObject.properties = <String, dynamic>{};
    // }
    // featureObject.properties?.putIfAbsent('selected', () => 'true');
    // await _controller?.setGeoJsonFeature(CampaignConstants.experienceAreaSourceName, featureObject.toJson());

    // var result = await _controller?.querySourceFeatures(
    //   CampaignConstants.experienceAreaSourceName,
    //   CampaignConstants.experienceAreaLayerId,
    //   null,
    // );

    // logger.d(result);

    var collection = turf.FeatureCollection(features: [featureObject]);
    await _controller!.setGeoJsonSource(CampaignConstants.experienceAreaSelectedSourceName, collection.toJson());
  }

  Future<void> unsetFocusToExperienceArea(Map<String, dynamic> feature) async {
    setState(() {
      _isInFocusMode = false;
    });
    // var featureObject = turf.Feature.fromJson(feature);
    // if (featureObject.properties == null) {
    //   logger.d('NULL ADDED');

    //   featureObject.properties = <String, dynamic>{};
    // }
    // featureObject.properties?.putIfAbsent('selected', () => 'false');

    // await _controller?.setGeoJsonFeature(CampaignConstants.experienceAreaSourceName, featureObject.toJson());

    await _controller!.setLayerProperties(
      CampaignConstants.experienceAreaLayerId,
      FillLayerProperties(visibility: 'visible'),
    );
    await _controller!.setLayerProperties(
      CampaignConstants.experienceAreaOutlineLayerId,
      LineLayerProperties(visibility: 'visible'),
    );
    removeLayerSource(CampaignConstants.experienceAreaSelectedSourceName);
  }

  SizedBox getPollingStationDetailWidget(turf.Feature pollingStationFeature) {
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

  Future<Widget> getRouteDetailWidget(turf.Feature routeFeature) async {
    var theme = Theme.of(context);
    var routeService = GetIt.I<GrueneApiRouteService>();
    var route = await routeService.getRoute(routeFeature.id.toString());

    onClose() => Navigator.maybePop(context);

    return SizedBox(
      height: 109,
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
        ],
      ),
    );
  }

  Future<Widget> getExperienceAreaDetailWidget(turf.Feature experienceAreaFeature) async {
    var theme = Theme.of(context);
    var experienceAreaService = GetIt.I<GrueneApiExperienceAreaService>();
    var experienceArea = await experienceAreaService.getExperienceArea(experienceAreaFeature.id.toString());

    onClose() => Navigator.maybePop(context);

    return SizedBox(
      height: 150,
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
                      Icon(Icons.radar_outlined),
                      SizedBox(width: 7),
                      Text(
                        t.campaigns.experience_areas.label,
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
                        experienceArea.description ?? '',
                        style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.experience_areas.supplied_by}: ${t.campaigns.experience_areas.general_supplier}',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.route.createdAt}: ${experienceArea.createdAt.getAsLocalDateString()}',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
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

class MyTriangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon([Offset(0, 0), Offset(size.width / 2, size.height), Offset(size.width, 0)], true);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
