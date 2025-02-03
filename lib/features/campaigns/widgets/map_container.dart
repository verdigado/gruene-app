import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/app_settings.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/helper/map_layer_manager.dart';
import 'package:gruene_app/features/campaigns/helper/marker_item_helper.dart';
import 'package:gruene_app/features/campaigns/helper/marker_item_manager.dart';
import 'package:gruene_app/features/campaigns/helper/util.dart';
import 'package:gruene_app/features/campaigns/location/determine_position.dart';
import 'package:gruene_app/features/campaigns/models/bounding_box.dart';
import 'package:gruene_app/features/campaigns/models/map_layer_model.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/features/campaigns/widgets/attribution_dialog.dart';
import 'package:gruene_app/features/campaigns/widgets/location_button.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller_simplified.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

typedef OnMapCreatedCallback = void Function(MapController controller);
typedef AddPOIClickedCallback = void Function(LatLng location);
typedef LoadVisibleItemsCallBack = void Function(LatLng locationSW, LatLng locationNE);
typedef LoadCachedItemsCallback = void Function();
typedef LoadDataLayersCallBack = void Function(LatLng locationSW, LatLng locationNE);
typedef GetMarkerImagesCallback = Map<String, String> Function();
typedef OnFeatureClickCallback = void Function(dynamic feature);
typedef OnNoFeatureClickCallback = void Function(Point<double> point);
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
  final OnFeatureClickCallback? onFeatureClick;
  final OnNoFeatureClickCallback? onNoFeatureClick;
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
    this.loadDataLayers,
    this.addMapLayersForContext,
    required this.locationAvailable,
    required this.showMapInfoAfterCameraMove,
    this.userLocation,
  });

  @override
  State<StatefulWidget> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> implements MapController, MapControllerSimplified {
  MapLibreMapController? _controller;
  final MarkerItemManager _markerItemManager = MarkerItemManager();
  final MapLayerDataManager _mapLayerManager = MapLayerDataManager();
  final appSettings = GetIt.I<AppSettings>();
  final campaignActionCache = GetIt.I<CampaignActionCache>();

  bool _isMapInitialized = false;
  bool _permissionGiven = false;
  final defaultStartLocation = CampaignConstants.centerGermany;

  static const minZoomMarkerItems = 11.5;
  static const double zoomLevelUserLocation = 16;
  static const double zoomLevelSearchLocation = 14.5;
  static const double zoomLevelUserOverview = 5.2;

  List<Widget> popups = [];
  List<Widget> infos = [];

  final _cameraTargetBounds = CampaignConstants.viewBoxGermany;

  var followUserLocation = true;

  bool _showAddMarker = true;

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

    Widget addMarker = SizedBox(
      height: 0,
      width: 0,
    );
    if (popups.isEmpty && _showAddMarker) {
      addMarker = Center(
        child: Container(
          padding: EdgeInsets.only(
            bottom: 65, /* height of the add_marker icon to position it exactly on the middle */
          ),
          child: GestureDetector(
            onTap: _onIconTap,
            child: SvgPicture.asset(CampaignConstants.addMarkerAssetName),
          ),
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
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => const AttributionDialog(),
                );
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

    List<dynamic> jsonFeatures = await getFeaturesInScreen(point, [CampaignConstants.markerLayerName]);
    final features = jsonFeatures.map((e) => e as Map<String, dynamic>).where((x) {
      // if (x.containsKey('id')) return true;
      if (x['properties'] == null) return false;
      final properties = x['properties'] as Map<String, dynamic>;
      if (properties['status_type'] == null) return false;
      return true;
    }).toList();

    if (features.isNotEmpty && onFeatureClick != null) {
      final feature = MapHelper.getClosestFeature(features, targetLatLng);
      onFeatureClick(feature);
    } else if (onNoFeatureClick != null) {
      onNoFeatureClick(point);
    }
  }

  @override
  Future<dynamic> getClosestFeaturesInScreen(
    Point<double> point,
    List<String> layers,
  ) async {
    var features = await getFeaturesInScreen(
      point,
      layers,
    );
    if (features.isNotEmpty) {
      final controller = _controller!;
      final targetLatLng = await controller.toLatLng(point);
      return MapHelper.getClosestFeature(features, targetLatLng);
    } else {
      return null;
    }
  }

  @override
  Future<List<dynamic>> getFeaturesInScreen(
    Point<double> point,
    List<String> layers,
  ) async {
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
        iconSize: 2,
        iconAllowOverlap: true,
      ),
      enableInteraction: false,
      minzoom: minZoomMarkerItems,
      filter: [
        '!',
        ['has', 'point_count'],
      ],
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
  void setLayerSource(String sourceId, List<MapLayerModel> layerData) async {
    _mapLayerManager.addLayerData(sourceId, layerData);
    final sourceIds = await _controller!.getSourceIds();
    Future<void> Function(Map<String, dynamic> data) setLayerData;
    if (sourceIds.contains(sourceId)) {
      setLayerData = (data) async {
        await _controller!.setGeoJsonSource(
          sourceId,
          data,
        );
      };
    } else {
      setLayerData = (data) async {
        await _controller!.addGeoJsonSource(
          sourceId,
          data,
        );
      };
    }
    final data = MarkerItemHelper.transformMapLayerDataToGeoJson(_mapLayerManager.getMapLayerData(sourceId)).toJson();
    await setLayerData(data);
  }

  @override
  void removeLayerSource(String sourceId) async {
    /* 
    * A bug prevents using correct method -> see https://github.com/maplibre/flutter-maplibre-gl/issues/526
    * Therefore we set it as empty datasource. Once the issue has been corrected we can use the designated method.
    */
    // await _controller!.removeSource(sourceId);
    await _controller!.setGeoJsonSource(sourceId, MarkerItemHelper.transformMapLayerDataToGeoJson([]).toJson());
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

    _showPopOver(
      point,
      widget,
      onEditItemClicked,
      desiredSize: desiredSize,
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
      final newTarget = LatLng(
        newLatitude ?? centerCoord.latitude,
        newLongitude ?? centerCoord.longitude,
      );
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
          child: Container(
            color: ThemeColors.secondary.withAlpha(30),
          ),
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
                decoration: BoxDecoration(
                  color: ThemeColors.background,
                  borderRadius: BorderRadius.circular(5),
                ),
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
                            child: Icon(
                              Icons.close,
                              size: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onTapPopup(onEditItemClicked),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 1.5, color: ThemeColors.textDark),
                                ),
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
                  child: Container(
                    color: ThemeColors.background,
                    width: 15,
                    height: heightArrowTriangle,
                  ),
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
                        Icon(
                          Icons.info,
                          color: ThemeColors.textCancel,
                          size: 24,
                        ),
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
}

class MyTriangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon(
      [
        Offset(0, 0),
        Offset(size.width / 2, size.height),
        Offset(size.width, 0),
      ],
      true,
    );
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
