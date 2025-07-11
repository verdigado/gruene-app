import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_base_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/helper/util.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:turf/turf.dart' as turf;

typedef GetAdditionalDataBeforeCallback<T> = Future<T?> Function(BuildContext);
typedef GetAddScreenCallback<T, U> = T Function(LatLng, AddressModel?, U?);
typedef SaveNewAndGetMarkerCallback<T> = Future<MarkerItemModel> Function(T);
typedef GetPoiCallback<T> = Future<T> Function();
typedef GetPoiDetailWidgetCallback<T> = Widget Function(T);
typedef GetPoiEditWidgetCallback<T> = Widget Function(T);
typedef OnDeletePoiCallback = Future<void> Function(String poiId);

abstract class MapConsumer<T extends StatefulWidget, PoiCreateType, PoiDetailType, PoiUpdateType> extends State<T>
    with InfoBox, SearchMixin<T> {
  late MapController mapController;

  final NominatimService _nominatimService = GetIt.I<NominatimService>();

  bool focusAreasVisible = false;
  bool pollingStationVisible = false;
  bool routesVisible = false;

  final _minZoomFocusAreaLayer = 11.0;
  final _minZoomPollingStationLayer = 11.0;
  final _minZoomRouteLayer = 11.0;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _lastInfoSnackBar;
  String? _lastFocusAreaId;
  final campaignActionCache = GetIt.I<CampaignActionCache>();
  final PoiServiceType poiType;

  MapConsumer(this.poiType);

  GrueneApiCampaignsPoiBaseService get campaignService;

  @override
  void dispose() {
    _lastInfoSnackBar?.close();
    super.dispose();
  }

  void onMapCreated(MapController controller) {
    mapController = controller;
  }

  void addPOIClicked<U, V extends Widget, W>(
    LatLng location,
    GetAdditionalDataBeforeCallback<U>? acquireAdditionalDataBefore,
    GetAddScreenCallback<V, U> getAddScreen,
    SaveNewAndGetMarkerCallback<W> saveAndGetMarker,
  ) async {
    var locationAddress = _nominatimService.getLocationAddress(location);
    U? additionalData;
    if (acquireAdditionalDataBefore != null) {
      additionalData = await acquireAdditionalDataBefore(context);
    }
    var navState = getNavState();
    final result = await navState.push(
      AppRoute<W?>(
        builder: (context) {
          return FutureBuilder(
            future: locationAddress.timeout(const Duration(milliseconds: 1300), onTimeout: () => AddressModel()),
            builder: (context, AsyncSnapshot<AddressModel> snapshot) {
              if (!snapshot.hasData || snapshot.hasError) {
                return Container(color: ThemeColors.secondary);
              }

              final address = snapshot.data;
              return ContentPage(
                title: getCurrentRoute().name ?? '',
                child: getAddScreen(location, address, additionalData),
              );
            },
          );
        },
      ),
    );

    if (result != null) {
      final markerItem = await saveAndGetMarker(result);
      mapController.addMarkerItem(markerItem);
    }
  }

  NavigatorState getNavState() => Navigator.of(context, rootNavigator: true);
  GoRouterState getCurrentRoute() => GoRouterState.of(context);

  Future<void> loadVisibleItems(LatLng locationSW, LatLng locationNE) async {
    if (mapController.getCurrentZoomLevel() > mapController.minimumMarkerZoomLevel) {
      final markerItems = await campaignService.loadPoisInRegion(locationSW, locationNE);
      mapController.setMarkerSource(markerItems);
    }
  }

  void onFeatureClick<U>(
    Map<String, dynamic> feature,
    GetPoiCallback<U> getPoi,
    GetPoiDetailWidgetCallback<U> getPoiDetail,
    GetPoiEditWidgetCallback<U> getPoiEdit, {
    Size desiredSize = const Size(100, 100),
    bool useBottomSheet = false,
  }) async {
    U poi = await getPoi();
    final poiDetailWidget = getPoiDetail(poi);
    if (useBottomSheet) {
      await mapController.setFocusToMarkerItem(feature);
      var result = await showDetailBottomSheet<ModalDetailResult>(poiDetailWidget);
      if (result != null && result == ModalDetailResult.edit) {
        _editPoi(() => getPoiEdit(poi));
      }
      await mapController.unsetFocusToMarkerItem();
    } else {
      var popupWidget = SizedBox(height: desiredSize.height, width: desiredSize.width, child: poiDetailWidget);
      final coord = MapHelper.extractLatLngFromFeature(feature);
      mapController.showMapPopover(coord, popupWidget, () => _editPoi(() => getPoiEdit(poi)), desiredSize);
    }
  }

  Future<U?> showDetailBottomSheet<U>(Widget detailWidget) async {
    final theme = Theme.of(context);
    return await showModalBottomSheet<U>(
      isScrollControlled: false,
      isDismissible: true,
      barrierColor: Colors.transparent,
      context: context,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => detailWidget,
    );
  }

  void _editPoi(Widget Function() getEditWidget) async {
    await showModalEditForm(context, getEditWidget);
  }

  static Future<ModalEditResult?> showModalEditForm(BuildContext context, Widget Function() getEditWidget) async {
    final theme = Theme.of(context);
    return await showModalBottomSheet<ModalEditResult>(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: getEditWidget(),
        ),
      ),
    );
  }

  Future<void> deletePoi(String poiId) async {
    var markerItem = await campaignActionCache.deletePoi(poiType, poiId);
    mapController.setMarkerSource([markerItem]);
  }

  void addMapLayersForContext(MapLibreMapController mapLibreController) async {
    await _addFocusAreaLayers(mapLibreController);
    await _addPollingStationLayer(mapLibreController);
    await _addRouteLayer(mapLibreController);
  }

  Future<void> _addFocusAreaLayers(MapLibreMapController mapLibreController) async {
    final data = <FocusArea>[].toList().transformToFeatureCollection().toJson();
    await mapLibreController.addGeoJsonSource(CampaignConstants.focusAreaSourceName, data);

    await mapLibreController.addFillLayer(
      CampaignConstants.focusAreaSourceName,
      CampaignConstants.focusAreaFillLayerId,
      FillLayerProperties(
        fillColor: [
          Expressions.interpolate,
          ['exponential', 0.5],
          [Expressions.zoom],
          18,
          ['get', 'score_color'],
        ],
        fillOpacity: ['get', 'score_opacity'],
      ),
      enableInteraction: false,
      minzoom: _minZoomFocusAreaLayer,
      belowLayerId: CampaignConstants.markerLayerName,
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.focusAreaSourceName,
      CampaignConstants.focusAreaBorderLayerId,
      LineLayerProperties(lineColor: ThemeColors.background.toHexStringRGB(), lineWidth: 1),
      minzoom: _minZoomFocusAreaLayer,
      enableInteraction: false,
    );
  }

  Future<void> _addPollingStationLayer(MapLibreMapController mapLibreController) async {
    final data = <PollingStation>[].toList().transformToFeatureCollection().toJson();
    addImageFromAsset(
      mapLibreController,
      CampaignConstants.pollingStationSourceName,
      CampaignConstants.pollingStationAssetName,
    );

    await mapLibreController.addGeoJsonSource(CampaignConstants.pollingStationSourceName, data);

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
      minzoom: _minZoomPollingStationLayer,
    );

    // add selected map layers
    await mapLibreController.addGeoJsonSource(
      CampaignConstants.pollingStationSelectedSourceName,
      turf.FeatureCollection().toJson(),
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
      minzoom: _minZoomPollingStationLayer,
    );
  }

  Future<void> _addRouteLayer(MapLibreMapController mapLibreController) async {
    final data = turf.FeatureCollection().toJson();

    await mapLibreController.addGeoJsonSource(CampaignConstants.routesSourceName, data);

    await mapLibreController.addLineLayer(
      CampaignConstants.routesSourceName,
      CampaignConstants.routesLineLayerId,
      LineLayerProperties(lineJoin: 'round', lineCap: 'round', lineColor: '#FF0000', lineWidth: 7, lineOpacity: 0.6),
      enableInteraction: false,
      minzoom: _minZoomRouteLayer,
    );

    // add selected map layers
    await mapLibreController.addGeoJsonSource(
      CampaignConstants.routesSelectedSourceName,
      turf.FeatureCollection().toJson(),
    );

    await mapLibreController.addLineLayer(
      CampaignConstants.routesSelectedSourceName,

      CampaignConstants.routesLineSelectedLayerId,
      LineLayerProperties(lineJoin: 'round', lineCap: 'round', lineColor: '#FF0000', lineWidth: 7, lineOpacity: 1),
      enableInteraction: false,
      minzoom: _minZoomPollingStationLayer,
    );
  }

  void onFocusAreaLayerStateChanged(bool state) async {
    focusAreasVisible = state;
    if (focusAreasVisible) {
      loadFocusAreaLayer();
      showInfoToast(
        t.campaigns.infoToast.focusAreas_activated,
        moreInfoCallback: () => showAboutInfoBox(
          context,
          t.campaigns.infoToast.focusAreas_aboutTitle,
          t.campaigns.infoToast.focusAreas_aboutText,
        ),
      );
    } else {
      mapController.removeLayerSource(CampaignConstants.focusAreaSourceName);
      hideCurrentSnackBar();
      showInfoToast(t.campaigns.infoToast.focusAreas_deactivated);
    }
  }

  void onRouteLayerStateChanged(bool state) async {
    routesVisible = state;
    if (routesVisible) {
      loadRouteLayer();
      showInfoToast(
        t.campaigns.infoToast.routes_activated,
        moreInfoCallback: () =>
            showAboutInfoBox(context, t.campaigns.infoToast.routes_aboutTitle, t.campaigns.infoToast.routes_aboutText),
      );
    } else {
      mapController.removeLayerSource(CampaignConstants.routesSourceName);
      showInfoToast(t.campaigns.infoToast.routes_deactivated);
    }
  }

  void onPollinStationLayerStateChanged(bool state) async {
    pollingStationVisible = state;
    if (pollingStationVisible) {
      loadPollingStationLayer();
    } else {
      mapController.removeLayerSource(CampaignConstants.pollingStationSourceName);
      mapController.removeLayerSource(CampaignConstants.pollingStationSelectedSourceName);
    }
  }

  void loadDataLayers(LatLng locationSW, LatLng locationNE) async {
    if (focusAreasVisible) {
      loadFocusAreaLayer();
    }
    if (pollingStationVisible) {
      loadPollingStationLayer();
    }
    if (routesVisible) {
      loadRouteLayer();
    }
  }

  void loadFocusAreaLayer() async {
    if (mapController.getCurrentZoomLevel() > _minZoomFocusAreaLayer) {
      final bbox = await mapController.getCurrentBoundingBox();

      final focusAreas = await campaignService.loadFocusAreasInRegion(bbox.southwest, bbox.northeast);
      mapController.setLayerSourceWithFeatureCollection(
        CampaignConstants.focusAreaSourceName,
        focusAreas.transformToFeatureCollection(),
      );
    } else {
      _lastInfoSnackBar?.close();
    }
  }

  void loadPollingStationLayer() async {
    if (mapController.getCurrentZoomLevel() > _minZoomPollingStationLayer) {
      final bbox = await mapController.getCurrentBoundingBox();

      final pollingStations = await campaignService.loadPollingStationsInRegion(bbox.southwest, bbox.northeast);
      mapController.setLayerSourceWithFeatureCollection(
        CampaignConstants.pollingStationSourceName,
        pollingStations.transformToFeatureCollection(),
      );
    } else {
      _lastInfoSnackBar?.close();
    }
  }

  void loadRouteLayer() async {
    if (mapController.getCurrentZoomLevel() > _minZoomRouteLayer) {
      final bbox = await mapController.getCurrentBoundingBox();

      final routes = await campaignService.loadRoutesInRegion(bbox.southwest, bbox.northeast);
      mapController.setLayerSourceWithFeatureCollection(
        CampaignConstants.routesSourceName,
        routes.transformToFeatureCollection(),
      );
    } else {
      _lastInfoSnackBar?.close();
    }
  }

  void showFocusAreaInfoAtPoint(Point<double> point) async {
    if (!focusAreasVisible) return;
    var features = await mapController.getFeaturesInScreen(point, [CampaignConstants.focusAreaFillLayerId]);
    if (features.isNotEmpty) {
      final feature = features.first;
      if (feature['properties'] == null) return;
      final properties = feature['properties'] as Map<String, dynamic>;
      var infoText = <String>[];

      String? currentFocusAreaId;
      if (properties['id'] != null) {
        currentFocusAreaId = properties['id'].toString();
        if (_lastFocusAreaId != null && _lastFocusAreaId == currentFocusAreaId) {
          hideCurrentSnackBar();
          return;
        }
      }
      if (properties['info'] != null) infoText.add(properties['info'] as String);
      if (properties['score_info'] != null) infoText.add(properties['score_info'] as String);

      if (infoText.isNotEmpty) {
        _lastFocusAreaId = currentFocusAreaId;
        _showInfo(infoText.join('\n'));
      }
    }
  }

  void showMapInfoAfterCameraMove() {
    var minZoomLevels = [_minZoomFocusAreaLayer, mapController.minimumMarkerZoomLevel];
    minZoomLevels.sort();
    var largestMinZoomLevel = minZoomLevels.last;
    var toggleEnableInfo = mapController.getCurrentZoomLevel() < largestMinZoomLevel;
    mapController.toggleInfoForMissingMapFeatures(toggleEnableInfo);
  }

  void hideCurrentSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _showInfo(String infoText) {
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.removeCurrentSnackBar();
    _lastInfoSnackBar = scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(infoText), duration: Duration(days: 1), showCloseIcon: true),
    );

    _lastInfoSnackBar!.closed.then((SnackBarClosedReason reason) {
      _lastFocusAreaId = null;
      _lastInfoSnackBar = null;
    });
  }

  void showInfoToast(String toastText, {void Function()? moreInfoCallback}) {
    final theme = Theme.of(context);

    List<Widget> showMoreInfo() {
      if (moreInfoCallback == null) return List<Widget>.empty();
      return [
        SizedBox(width: 12),
        Text(
          t.campaigns.infoToast.more,
          style: theme.textTheme.labelMedium!.apply(color: ThemeColors.textDark, decoration: TextDecoration.underline),
        ),
      ];
    }

    MotionToast? toast;
    tapToast() {
      toast!.closeOverlay();
      moreInfoCallback!();
    }

    toast = MotionToast(
      icon: Icons.info_outlined,
      secondaryColor: ThemeColors.textCancel,
      primaryColor: ThemeColors.infoBackground,
      width: 300,
      height: 80,
      description: GestureDetector(
        onTap: tapToast,
        child: Row(
          children: [
            Text(toastText, style: theme.textTheme.labelMedium!.apply(color: ThemeColors.textDark)),
            ...showMoreInfo(),
          ],
        ),
      ),
    );

    toast.show(context);
  }

  @override
  void navigateMapTo(LatLng location) {
    mapController.navigateMapTo(location);
  }

  void loadCachedItems() async {
    var markerItems = await campaignActionCache.getMarkerItems(poiType);
    mapController.setMarkerSource(markerItems);
  }

  Future<void> savePoi(PoiUpdateType poiUpdate) async {
    final updatedMarker = await campaignActionCache.updatePoi(poiType, poiUpdate);
    mapController.setMarkerSource([updatedMarker]);
  }

  Future<MarkerItemModel> saveNewAndGetMarkerItem(PoiCreateType newPoi) async =>
      await campaignActionCache.storeNewPoi(poiType, newPoi);

  Future<U> getPoiFromFeature<U extends BasicPoi>(Map<String, dynamic> feature) {
    final isCached = MapHelper.extractIsCachedFromFeature(feature);
    var getPoiFromCacheOrApi = isCached ? getCachedPoi : getPoi;
    final poiId = MapHelper.extractPoiIdFromFeature(feature);
    return getPoiFromCacheOrApi(poiId) as Future<U>;
  }

  Future<PoiDetailType> getCachedPoi(String poiId);
  Future<PoiDetailType> getPoi(String poiId);
}
