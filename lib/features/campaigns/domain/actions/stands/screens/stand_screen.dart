import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/api/stand_api_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_add_screen.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/map_with_location.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Map of the Stand tab.
///
/// Shows all stands of the campaign, past ones included, plus those still waiting in the offline queue.
/// No route or area layers. Detail and editing of a stand are #1277.
class StandScreen extends StatefulWidget {
  const StandScreen({super.key});

  @override
  State<StandScreen> createState() => _StandScreenState();
}

class _StandScreenState extends MapConsumer<StandScreen, StandCreateModel, StandDetailModel, StandUpdateModel> {
  static const _poiType = PoiServiceType.stand;
  final _standApiService = GetIt.I<StandApiService>();

  _StandScreenState() : super(_poiType);

  @override
  StandApiService get campaignService => _standApiService;

  @override
  Widget build(BuildContext context) {
    return MapWithLocation(
      mapContainerController: mapContainerController,
      onMapCreated: onMapCreated,
      addPOIClicked: _addPOIClicked,
      loadVisiblePois: loadVisiblePois,
      getMarkerImages: () => {_poiType.name: CampaignConstants.standAssetName},
      getBasicPoiFromFeature: (feature) => getPoiFromFeature<BasicPoi>(feature),
      onFeatureClick: null,
      onNoFeatureClick: null,
      showBottomDetailSheet: showDetailBottomSheet,
      showMapInfoAfterCameraMove: null,
      addMapLayersForContext: (_) async {},
    );
  }

  void _addPOIClicked(LatLng location) {
    super.addPOIClicked<Object, StandAddScreen, StandCreateModel>(
      location,
      null,
      (location, address, _) => StandAddScreen(location: location, address: address ?? AddressModel()),
      saveNewAndGetMarkerItem,
    );
  }

  @override
  Future<StandDetailModel> getPoi(String poiId) => campaignService.getPoiAsStandDetail(poiId);

  @override
  Future<StandDetailModel> getCachedPoi(String poiId) => campaignActionCache.getPoiAsStandDetail(poiId);
}
