import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_create_model.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_update_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/app/services/api/door_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/screens/door_edit.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/screens/doors_add_screen.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/screens/doors_detail.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/map_with_location.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/filter_chip_widget.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_info_type.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class DoorsScreen extends StatefulWidget {
  const DoorsScreen({super.key});

  @override
  State<DoorsScreen> createState() => _DoorsScreenState();
}

class _DoorsScreenState extends MapConsumer<DoorsScreen, DoorCreateModel, DoorDetailModel, DoorUpdateModel> {
  static const _poiType = PoiServiceType.door;
  late List<FilterChipModel> doorsFilter;
  final _grueneApiService = GetIt.I<DoorApiService>();

  _DoorsScreenState() : super(_poiType);

  @override
  DoorApiService get campaignService => _grueneApiService;

  @override
  void initState() {
    doorsFilter = [
      FilterChipModel(
        text: t.campaigns.filters.routes,
        isEnabled: true,
        stateChanged: (state) => onRouteLayerStateChanged(state, getMapInfo(MapInfoType.experienceArea)),
      ),
      FilterChipModel(
        text: t.campaigns.filters.actionAreas,
        isEnabled: true,
        isActive: true,
        stateChanged: (state) => onActionAreaLayerStateChanged(state, getMapInfo(MapInfoType.actionArea)),
      ),
      FilterChipModel(
        text: t.campaigns.filters.focusAreas,
        isEnabled: true,
        stateChanged: (state) => onFocusAreaLayerStateChanged(state, getMapInfo(MapInfoType.focusArea)),
      ),
      FilterChipModel(
        text: t.campaigns.filters.experienceAreas,
        isEnabled: true,
        stateChanged: (state) => onExperienceAreaLayerStateChanged(state, getMapInfo(MapInfoType.experienceArea)),
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mapContainer = MapWithLocation(
      mapContainerController: mapContainerController,
      onMapCreated: onMapCreated,
      addPOIClicked: _addPOIClicked,
      loadVisiblePois: loadVisiblePois,
      getMarkerImages: _getMarkerImages,
      onFeatureClick: _onFeatureClick,
      onNoFeatureClick: _onNoFeatureClick,
      showBottomDetailSheet: showDetailBottomSheet,
      addMapLayersForContext: addMapLayersForContext,
      loadDataLayers: loadDataLayers,
      showMapInfoAfterCameraMove: showMapInfoAfterCameraMove,
      getBasicPoiFromFeature: (feature) => getPoiFromFeature<BasicPoi>(feature),
    );

    return Column(
      children: [
        FilterChipCampaign(filterOptions: doorsFilter, filterController: filterController),
        Expanded(child: Stack(children: [mapContainer, ...getSearchWidgets(context)])),
      ],
    );
  }

  void _addPOIClicked(LatLng location) {
    super.addPOIClicked<Object, DoorsAddScreen, DoorCreateModel>(
      location,
      null,
      _getAddScreen,
      saveNewAndGetMarkerItem,
    );
  }

  Map<String, String> _getMarkerImages() {
    return {'door': CampaignConstants.doorAssetName};
  }

  void _onFeatureClick(dynamic rawFeature) async {
    final feature = rawFeature as Map<String, dynamic>;

    getPoiDetail(DoorDetailModel door) {
      return DoorsDetail(poi: door);
    }

    getEditPoiWidget(DoorDetailModel door) {
      return DoorEdit(door: door, onSave: savePoi, onDelete: deletePoi);
    }

    super.onFeatureClick<DoorDetailModel>(
      rawFeature,
      () => getPoiFromFeature<DoorDetailModel>(feature),
      getPoiDetail,
      getEditPoiWidget,
      desiredSize: Size(145, 110),
    );
  }

  @override
  getPoi(String poiId) {
    return campaignService.getPoiAsDoorDetail(poiId);
  }

  @override
  getCachedPoi(String poiId) {
    return campaignActionCache.getPoiAsDoorDetail(poiId);
  }

  void _onNoFeatureClick(Point<double> point) {
    showFocusAreaInfoAtPoint(point);
  }

  DoorsAddScreen _getAddScreen(LatLng location, AddressModel? address, Object? additionalData) {
    return DoorsAddScreen(location: location, address: address!);
  }
}
