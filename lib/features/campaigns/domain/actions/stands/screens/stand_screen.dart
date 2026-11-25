import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/api/stand_api_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_add_screen.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_detail.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_edit.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/map_with_location.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Map of the Stand tab.
///
/// Shows all stands of the campaign, past ones included, plus those still waiting in the offline queue.
/// No route or area layers. Tapping a stand opens its detail in a bottom sheet, where its Termine are managed, and
/// from there the edit view of its base data (#1277).
class StandScreen extends StatefulWidget {
  const StandScreen({super.key});

  @override
  State<StandScreen> createState() => _StandScreenState();
}

class _StandScreenState extends MapConsumer<StandScreen, StandCreateModel, StandDetailModel, StandUpdateModel> {
  static const _poiType = PoiServiceType.stand;
  final _standApiService = GetIt.I<StandApiService>();

  /// The stand as changed by Termin edits in its detail. The edit view opened from there starts from it, so saving
  /// the stand does not bring back a changed or deleted Termin.
  StandDetailModel? _changedStand;

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
      onFeatureClick: _onFeatureClick,
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

  void _onFeatureClick(dynamic rawFeature) {
    final feature = rawFeature as Map<String, dynamic>;
    _changedStand = null;
    super.onFeatureClick<StandDetailModel>(
      feature,
      () => getPoiFromFeature<StandDetailModel>(feature),
      (stand) => StandDetail(poi: stand, onSaveEntry: _saveEntry, onDeleteEntry: _deleteEntry),
      (stand) => StandEdit(stand: _changedStand ?? stand, onSave: savePoi, onDelete: deletePoi),
      useBottomSheet: true,
    );
  }

  /// Queues the change of a Termin and returns the stand with all its queued changes, including the provisional
  /// flyer total.
  Future<StandDetailModel> _saveEntry(StandDetailModel stand, StandEntryUpdateModel entry) async {
    final marker = await campaignActionCache.updateStandEntry(stand.id, entry, stand);
    mapController.setPoiMarkerSource([marker]);
    return _changedStand = await campaignActionCache.getPoiAsStandDetail(stand.id);
  }

  Future<StandDetailModel> _deleteEntry(StandDetailModel stand, String entryId) async {
    final marker = await campaignActionCache.deleteStandEntry(stand.id, entryId, stand);
    mapController.setPoiMarkerSource([marker]);
    return _changedStand = await campaignActionCache.getPoiAsStandDetail(stand.id);
  }

  @override
  Future<StandDetailModel> getPoi(String poiId) => campaignService.getPoiAsStandDetail(poiId);

  @override
  Future<StandDetailModel> getCachedPoi(String poiId) => campaignActionCache.getPoiAsStandDetail(poiId);
}
