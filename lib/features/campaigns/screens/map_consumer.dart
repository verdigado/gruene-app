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
import 'package:gruene_app/features/campaigns/helper/map_info.dart';
import 'package:gruene_app/features/campaigns/helper/map_info_type.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/features/campaigns/widgets/focus_area_gen2_info_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:turf/turf.dart' as turf;

typedef GetAdditionalDataBeforeCallback<T> = Future<T?> Function(BuildContext);
typedef GetAddScreenCallback<T, U> = T Function(LatLng, AddressModel?, U?);
typedef SaveNewAndGetMarkerCallback<T> = Future<turf.Feature> Function(T);
typedef GetPoiCallback<T> = Future<T> Function();
typedef GetPoiDetailWidgetCallback<T> = Widget Function(T);
typedef GetPoiEditWidgetCallback<T> = Widget Function(T);
typedef OnDeletePoiCallback = Future<void> Function(String poiId);
typedef LoadCachedLayerCallback = void Function(PoiCacheType cacheType, String layerSourceName);

abstract class MapConsumer<T extends StatefulWidget, PoiCreateType, PoiDetailType, PoiUpdateType> extends State<T>
    with
        InfoBox,
        SearchMixin<T>,
        MapConsumerActionAreaMixin,
        MapConsumerExperienceAreaMixin,
        MapConsumerRouteMixin,
        MapConsumerFocusAreaMixin,
        MapConsumerPollingStationMixin {
  late MapController mapController;

  final NominatimService _nominatimService = GetIt.I<NominatimService>();

  final _minZoomFocusAreaLayer = 11.0;
  final _minZoomPollingStationLayer = 11.0;
  final _minZoomRouteLayer = 11.0;
  final _minZoomExperienceAreaLayer = 11.0;
  final _minZoomActionAreaLayer = 11.0;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _lastInfoSnackBar;
  String? _lastFocusAreaId;
  final campaignActionCache = GetIt.I<CampaignActionCache>();
  final PoiServiceType poiType;

  MapConsumer(this.poiType);

  @override
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
                title: getCurrentRoute().name.safe(),
                child: getAddScreen(location, address, additionalData),
              );
            },
          );
        },
      ),
    );

    if (result != null) {
      final markerItem = await saveAndGetMarker(result);
      mapController.addPoiMarkerItem(markerItem);
    }
  }

  NavigatorState getNavState() => Navigator.of(context, rootNavigator: true);
  GoRouterState getCurrentRoute() => GoRouterState.of(context);

  void _loadCachedPois() async {
    var markerItems = await campaignActionCache.getLayerItems(poiType.asPoiCacheType());
    mapController.setPoiMarkerSource(markerItems);
  }

  void _loadCachedLayer(PoiCacheType cacheType, String layerSourceName) async {
    var layerItems = await campaignActionCache.getLayerItems(cacheType);
    mapController.setLayerSourceWithFeatureList(layerSourceName, layerItems);
  }

  Future<void> loadVisiblePois(LatLng locationSW, LatLng locationNE, bool loadCached) async {
    if (loadCached) _loadCachedPois();
    if (mapController.getCurrentZoomLevel() > mapController.minimumMarkerZoomLevel) {
      final markerItems = await campaignService.loadPoisInRegion(locationSW, locationNE);
      mapController.setPoiMarkerSource(markerItems.transformToFeatureList());
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
    var markerItem = await campaignActionCache.deletePoi(poiType.asPoiCacheType(), poiId);
    mapController.setPoiMarkerSource([markerItem]);
  }

  void addMapLayersForContext(MapLibreMapController mapLibreController) async {
    await addFocusAreaLayers(mapLibreController, getMapInfo(MapInfoType.focusArea));
    await addPollingStationLayer(mapLibreController, getMapInfo(MapInfoType.pollingStation));
    await addRouteLayer(mapLibreController, getMapInfo(MapInfoType.route));
    await addExperienceAreaLayer(mapLibreController, getMapInfo(MapInfoType.experienceArea));
    await addActionAreaLayer(mapLibreController, getMapInfo(MapInfoType.actionArea));
  }

  void loadDataLayers(LatLng locationSW, LatLng locationNE, bool loadCached) async {
    if (focusAreasVisible) {
      loadFocusAreaLayer(getMapInfo(MapInfoType.focusArea));
    }
    if (pollingStationVisible) {
      loadPollingStationLayer(getMapInfo(MapInfoType.pollingStation));
    }
    if (routesVisible) {
      loadRouteLayer(getMapInfo(MapInfoType.route), loadCached);
    }
    if (experienceAreasVisible) {
      loadExperienceAreaLayer(getMapInfo(MapInfoType.experienceArea));
    }
    if (actionAreasVisible) {
      loadActionAreaLayer(getMapInfo(MapInfoType.actionArea), loadCached);
    }
  }

  void showFocusAreaInfoAtPoint(Point<double> point) async {
    if (!focusAreasVisible) return;
    var features = await mapController.getFeaturesInScreen(point, [CampaignConstants.focusAreaFillLayerId]);
    if (features.isNotEmpty) {
      final feature = turf.Feature.fromJson(features.first as Map<String, dynamic>);
      if (feature.properties == null) return;
      final properties = feature.properties!;
      var infoText = <String>[];

      var currentFocusAreaId = feature.id.toString();

      if (_lastFocusAreaId != null && _lastFocusAreaId == currentFocusAreaId) {
        hideCurrentSnackBar();
        return;
      }
      var focusAreaType = FocusAreaType.values.byName(properties[CampaignConstants.focusAreaMapTypeProperty] as String);

      if (focusAreaType == FocusAreaType.gen2) {
        hideCurrentSnackBar();
        showFocusAreaGen2(currentFocusAreaId);
      } else {
        if (properties[CampaignConstants.focusAreaMapInfoProperty] != null) {
          infoText.add(properties[CampaignConstants.focusAreaMapInfoProperty] as String);
        }
        if (properties[CampaignConstants.focusAreaMapScoreInfoProperty] != null) {
          infoText.add(properties[CampaignConstants.focusAreaMapScoreInfoProperty] as String);
        }

        if (infoText.isNotEmpty) {
          _lastFocusAreaId = currentFocusAreaId;
          _showInfo(infoText.join('\n'));
        }
      }
    }
  }

  Future<void> showFocusAreaGen2(String currentFocusAreaId) async {
    var focusArea = await campaignService.loadFocusArea(currentFocusAreaId);

    if (mounted) {
      var theme = Theme.of(context);
      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => FocusAreaGen2InfoWidget(focusArea: focusArea, poiType: poiType),
        isScrollControlled: false,
        isDismissible: true,
        backgroundColor: theme.colorScheme.surface,
      );
    }
  }

  void showMapInfoAfterCameraMove() {
    var minZoomLevels = [_minZoomFocusAreaLayer, mapController.minimumMarkerZoomLevel];
    minZoomLevels.sort();
    var largestMinZoomLevel = minZoomLevels.last;
    var toggleEnableInfo = mapController.getCurrentZoomLevel() < largestMinZoomLevel;
    mapController.toggleInfoForMissingMapFeatures(toggleEnableInfo);
  }

  @override
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

  @override
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

  Future<void> savePoi(PoiUpdateType poiUpdate) async {
    final updatedMarker = await campaignActionCache.updatePoi(poiType.asPoiCacheType(), poiUpdate);
    mapController.setPoiMarkerSource([updatedMarker]);
  }

  Future<turf.Feature> saveNewAndGetMarkerItem(PoiCreateType newPoi) async =>
      await campaignActionCache.storeNewPoi(poiType.asPoiCacheType(), newPoi);

  Future<U> getPoiFromFeature<U extends BasicPoi>(Map<String, dynamic> feature) {
    final isCached = MapHelper.extractIsCachedFromFeature(feature);
    var getPoiFromCacheOrApi = isCached ? getCachedPoi : getPoi;
    final poiId = MapHelper.extractPoiIdFromFeature(feature);
    return getPoiFromCacheOrApi(poiId) as Future<U>;
  }

  MapInfo getMapInfo(MapInfoType infoType) {
    var minZoom = switch (infoType) {
      MapInfoType.experienceArea => _minZoomExperienceAreaLayer,
      MapInfoType.focusArea => _minZoomFocusAreaLayer,
      MapInfoType.pollingStation => _minZoomPollingStationLayer,
      MapInfoType.route => _minZoomRouteLayer,
      MapInfoType.actionArea => _minZoomActionAreaLayer,
    };

    return MapInfo(
      mapController: mapController,
      minZoom: minZoom,
      lastInfoSnackbar: _lastInfoSnackBar,
      context: context,
      loadCachedLayer: _loadCachedLayer,
    );
  }

  Future<PoiDetailType> getCachedPoi(String poiId);
  Future<PoiDetailType> getPoi(String poiId);
}
