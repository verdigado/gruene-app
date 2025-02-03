import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_flyer_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_create_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_update_model.dart';
import 'package:gruene_app/features/campaigns/screens/flyer_add_screen.dart';
import 'package:gruene_app/features/campaigns/screens/flyer_detail.dart';
import 'package:gruene_app/features/campaigns/screens/flyer_edit.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/widgets/filter_chip_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/map_with_location.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class FlyerScreen extends StatefulWidget {
  const FlyerScreen({super.key});

  @override
  State<FlyerScreen> createState() => _FlyerScreenState();
}

class _FlyerScreenState extends MapConsumer<FlyerScreen, FlyerCreateModel, FlyerUpdateModel> {
  static const _poiType = PoiServiceType.flyer;
  final _grueneApiService = GetIt.I<GrueneApiFlyerService>();

  late List<FilterChipModel> flyerFilter;

  _FlyerScreenState() : super(_poiType);

  @override
  void initState() {
    flyerFilter = [
      FilterChipModel(
        text: t.campaigns.filters.visited_areas,
        isEnabled: false,
      ),
      FilterChipModel(
        text: t.campaigns.filters.focusAreas,
        isEnabled: true,
        stateChanged: onFocusAreaStateChanged,
      ),
      FilterChipModel(
        text: t.campaigns.filters.routes,
        isEnabled: false,
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
        FilterChipCampaign(flyerFilter, <String, List<String>>{}),
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
    super.addPOIClicked<Object, FlyerAddScreen, FlyerCreateModel>(
      location,
      null,
      _getAddScreen,
      saveNewAndGetMarkerItem,
    );
  }

  Map<String, String> _getMarkerImages() {
    return {
      'flyer': CampaignConstants.flyerAssetName,
    };
  }

  void _onFeatureClick(dynamic rawFeature) async {
    final feature = rawFeature as Map<String, dynamic>;
    final isCached = MapHelper.extractIsCachedFromFeature(feature);

    getPoi(String poiId) async {
      final flyer = await campaignService.getPoiAsFlyerDetail(poiId);
      return flyer;
    }

    getCachedPoi(String poiId) async {
      final flyer = await campaignActionCache.getPoiAsFlyerDetail(poiId);
      return flyer;
    }

    var getPoiFromCacheOrApi = isCached ? getCachedPoi : getPoi;

    getPoiDetail(FlyerDetailModel flyer) {
      return FlyerDetail(
        poi: flyer,
      );
    }

    getEditPoiWidget(FlyerDetailModel flyer) {
      return FlyerEdit(flyer: flyer, onSave: savePoi, onDelete: deletePoi);
    }

    super.onFeatureClick<FlyerDetailModel>(
      rawFeature,
      getPoiFromCacheOrApi,
      getPoiDetail,
      getEditPoiWidget,
      desiredSize: Size(150, 92),
    );
  }

  void _onNoFeatureClick(Point<double> point) {
    showFocusAreaInfoAtPoint(point);
  }

  @override
  GrueneApiFlyerService get campaignService => _grueneApiService;

  FlyerAddScreen _getAddScreen(LatLng location, AddressModel? address, Object? additionalData) {
    return FlyerAddScreen(
      location: location,
      address: address!,
    );
  }
}
