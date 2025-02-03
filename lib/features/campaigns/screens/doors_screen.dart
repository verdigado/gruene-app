import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_door_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_create_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_update_model.dart';
import 'package:gruene_app/features/campaigns/screens/door_edit.dart';
import 'package:gruene_app/features/campaigns/screens/doors_add_screen.dart';
import 'package:gruene_app/features/campaigns/screens/doors_detail.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/widgets/filter_chip_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/map_with_location.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class DoorsScreen extends StatefulWidget {
  const DoorsScreen({super.key});

  @override
  State<DoorsScreen> createState() => _DoorsScreenState();
}

class _DoorsScreenState extends MapConsumer<DoorsScreen, DoorCreateModel, DoorUpdateModel> {
  static const _poiType = PoiServiceType.door;
  final Map<String, List<String>> doorsExclusions = <String, List<String>>{
    t.campaigns.filters.focusAreas: [t.campaigns.filters.visited_areas],
    t.campaigns.filters.visited_areas: [t.campaigns.filters.focusAreas],
  };

  late List<FilterChipModel> doorsFilter;

  final _grueneApiService = GetIt.I<GrueneApiDoorService>();

  _DoorsScreenState() : super(_poiType);

  @override
  GrueneApiDoorService get campaignService => _grueneApiService;

  @override
  void initState() {
    doorsFilter = [
      FilterChipModel(
        text: t.campaigns.filters.visited_areas,
        isEnabled: false,
      ),
      FilterChipModel(
        text: t.campaigns.filters.routes,
        isEnabled: false,
      ),
      FilterChipModel(
        text: t.campaigns.filters.focusAreas,
        isEnabled: true,
        stateChanged: onFocusAreaStateChanged,
      ),
      FilterChipModel(
        text: t.campaigns.filters.experience_areas,
        isEnabled: false,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mapContainer = MapWithLocation(
      onMapCreated: onMapCreated,
      addPOIClicked: _addPOIClicked,
      loadVisibleItems: loadVisibleItems,
      loadCachedItems: loadCachedItems,
      getMarkerImages: _getMarkerImages,
      onFeatureClick: _onFeatureClick,
      onNoFeatureClick: _onNoFeatureClick,
      addMapLayersForContext: addMapLayersForContext,
      loadDataLayers: loadDataLayers,
      showMapInfoAfterCameraMove: showMapInfoAfterCameraMove,
    );

    return Column(
      children: [
        FilterChipCampaign(doorsFilter, doorsExclusions),
        Expanded(
          child: Stack(
            children: [
              mapContainer,
              ...getSearchWidgets(context),
            ],
          ),
        ),
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
    return {
      'door': CampaignConstants.doorAssetName,
    };
  }

  void _onFeatureClick(dynamic rawFeature) async {
    final feature = rawFeature as Map<String, dynamic>;
    final isCached = MapHelper.extractIsCachedFromFeature(feature);

    getPoi(String poiId) async {
      final door = await campaignService.getPoiAsDoorDetail(poiId);
      return door;
    }

    getCachedPoi(String poiId) async {
      final door = await campaignActionCache.getPoiAsDoorDetail(poiId);
      return door;
    }

    var getPoiFromCacheOrApi = isCached ? getCachedPoi : getPoi;

    getPoiDetail(DoorDetailModel door) {
      return DoorsDetail(
        poi: door,
      );
    }

    getEditPoiWidget(DoorDetailModel door) {
      return DoorEdit(door: door, onSave: savePoi, onDelete: deletePoi);
    }

    super.onFeatureClick<DoorDetailModel>(
      rawFeature,
      getPoiFromCacheOrApi,
      getPoiDetail,
      getEditPoiWidget,
      desiredSize: Size(145, 110),
    );
  }

  void _onNoFeatureClick(Point<double> point) {
    showFocusAreaInfoAtPoint(point);
  }

  DoorsAddScreen _getAddScreen(LatLng location, AddressModel? address, Object? additionalData) {
    return DoorsAddScreen(
      location: location,
      address: address!,
    );
  }
}
