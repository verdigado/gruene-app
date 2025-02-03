import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/helper/marker_item_helper.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:motion_toast/motion_toast.dart';

typedef GetAdditionalDataBeforeCallback<T> = Future<T?> Function(BuildContext);
typedef GetAddScreenCallback<T, U> = T Function(LatLng, AddressModel?, U?);
typedef SaveNewAndGetMarkerCallback<T> = Future<MarkerItemModel> Function(T);
typedef GetPoiCallback<T> = Future<T> Function(String);
typedef GetPoiDetailWidgetCallback<T> = Widget Function(T);
typedef GetPoiEditWidgetCallback<T> = Widget Function(T);
typedef OnDeletePoiCallback = Future<void> Function(String poiId);

abstract class MapConsumer<T extends StatefulWidget, PoiCreateType, PoiUpdateType> extends State<T>
    with FocusAreaInfo, SearchMixin<T> {
  late MapController mapController;

  final NominatimService _nominatimService = GetIt.I<NominatimService>();

  bool focusAreasVisible = false;
  final String _focusAreadId = 'focusArea';
  final _minZoomFocusAreaLayer = 11.0;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _lastInfoSnackBar;
  String? _lastFocusAreaId;
  final campaignActionCache = GetIt.I<CampaignActionCache>();
  final PoiServiceType poiType;

  MapConsumer(this.poiType);

  GrueneApiCampaignsService get campaignService;

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
              if (!snapshot.hasData && !snapshot.hasError) {
                return Container(
                  color: ThemeColors.secondary,
                );
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
    dynamic rawFeature,
    GetPoiCallback<U> getPoi,
    GetPoiDetailWidgetCallback<U> getPoiDetail,
    GetPoiEditWidgetCallback<U> getPoiEdit, {
    Size desiredSize = const Size(100, 100),
  }) async {
    final feature = rawFeature as Map<String, dynamic>;
    final poiId = MapHelper.extractPoiIdFromFeature(feature);
    U poi = await getPoi(poiId);
    final poiDetailWidget = getPoiDetail(poi);
    var popupWidget = SizedBox(
      height: desiredSize.height,
      width: desiredSize.width,
      child: poiDetailWidget,
    );
    final coord = MapHelper.extractLatLngFromFeature(feature);
    mapController.showMapPopover(
      coord,
      popupWidget,
      () => _editPoi(() => getPoiEdit(poi)),
      desiredSize,
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
    final focusAreaBorderLayerId = '${_focusAreadId}_border';

    final data = MarkerItemHelper.transformMapLayerDataToGeoJson([]).toJson();
    await mapLibreController.addGeoJsonSource(
      _focusAreadId,
      data,
    );

    await mapLibreController.addFillLayer(
      _focusAreadId,
      focusAreaFillLayerId,
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
      _focusAreadId,
      focusAreaBorderLayerId,
      LineLayerProperties(lineColor: ThemeColors.background.toHexStringRGB(), lineWidth: 1),
      minzoom: _minZoomFocusAreaLayer,
      enableInteraction: false,
    );
  }

  void onFocusAreaStateChanged(bool state) async {
    focusAreasVisible = state;
    if (focusAreasVisible) {
      loadFocusAreaLayer();
      showInfoToast(t.campaigns.infoToast.focusAreas_activated, moreInfoCallback: () => showAboutFocusArea(context));
    } else {
      mapController.removeLayerSource(_focusAreadId);
      hideCurrentSnackBar();
      showInfoToast(t.campaigns.infoToast.focusAreas_deactivated);
    }
  }

  String get focusAreaFillLayerId => '${_focusAreadId}_layer';
  void loadDataLayers(LatLng locationSW, LatLng locationNE) async {
    if (focusAreasVisible) {
      loadFocusAreaLayer();
    }
  }

  void loadFocusAreaLayer() async {
    if (mapController.getCurrentZoomLevel() > _minZoomFocusAreaLayer) {
      final bbox = await mapController.getCurrentBoundingBox();

      final focusAreas = await campaignService.loadFocusAreasInRegion(bbox.southwest, bbox.northeast);
      mapController.setLayerSource(_focusAreadId, focusAreas);
    } else {
      _lastInfoSnackBar?.close();
    }
  }

  void showFocusAreaInfoAtPoint(Point<double> point) async {
    if (!focusAreasVisible) return;
    var features = await mapController.getFeaturesInScreen(
      point,
      [focusAreaFillLayerId],
    );
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
      SnackBar(
        content: Text(
          infoText,
        ),
        duration: Duration(days: 1),
        showCloseIcon: true,
      ),
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
        SizedBox(
          width: 12,
        ),
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
      icon: Icons.info,
      secondaryColor: ThemeColors.textCancel,
      primaryColor: ThemeColors.infoBackground,
      width: 300,
      height: 80,
      description: GestureDetector(
        onTap: tapToast,
        child: Row(
          children: [
            Text(
              toastText,
              style: theme.textTheme.labelMedium!.apply(
                color: ThemeColors.textDark,
              ),
            ),
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
}
