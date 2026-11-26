import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/services/api/base_poi_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

/// Stands are pins of type `STAND`; their Termine (entries) have calls of their own.
/// Every Termin call returns the stand with all its Termine and the new flyer total.
class StandApiService extends BasePoiApiService {
  StandApiService() : super(poiType: PoiServiceType.stand);

  /// The map shows every stand of the campaign, also those created before `POI_FILTER_DATE`.
  @override
  bool filterByCutOffDate(Poi poi) => true;

  /// Creates the stand with its first Termin, without its photos: the offline queue uploads them as a change of the
  /// created stand, so that a failed upload is retried without creating the stand again.
  Future<StandDetailModel> createNewStand(StandCreateModel newStand) => send(
    request: (api) => api.v1CampaignsPoisPost(
      body: CreatePoi(
        campaignId: newStand.campaignId,
        coords: newStand.location.toGeoJsonCoords(),
        type: poiType.toApiPoisType(),
        address: newStand.address.toPoiAddress(),
        stand: CreatePoiStand(
          name: newStand.name,
          description: newStand.description,
          comment: newStand.comment,
          firstEntry: CreatePoiStandEntry(
            startAt: newStand.firstEntry.startAt.toUtc(),
            endAt: newStand.firstEntry.endAt.toUtc(),
            flyerCount: newStand.firstEntry.flyerCount?.toDouble(),
          ),
        ),
      ),
    ),
    map: (poi) => poi.toStandDetail(),
  );

  Future<PoiDetailModel> updateStand(StandUpdateModel standUpdate, {OnPhotoStep? onPhotoStep}) async {
    final poi = await send<Poi, Poi>(
      request: (api) => api.v1CampaignsPoisPoiIdPut(
        poiId: standUpdate.id,
        body: UpdatePoi(
          address: standUpdate.address.toPoiAddress(),
          stand: PoiStand(name: standUpdate.name, description: standUpdate.description, comment: standUpdate.comment),
        ),
      ),
    );
    final poiWithPhotos = await updatePhotos(
      standUpdate.id,
      deletedPhotoIds: standUpdate.deletedPhotoIds,
      newImageFileLocations: standUpdate.newPhotos.map((photo) => photo.imageUrl),
      onPhotoStep: onPhotoStep,
    );
    return (poiWithPhotos ?? poi).toMarkerItem();
  }

  Future<StandDetailModel> getPoiAsStandDetail(String poiId) => getPoi(poiId, (p) => p.toStandDetail());

  Future<StandDetailModel> addStandEntry(String standId, StandEntryCreateModel entry) => send(
    request: (api) => api.v1CampaignsPoisPoiIdEntriesPost(
      poiId: standId,
      body: CreatePoiStandEntry(
        startAt: entry.startAt.toUtc(),
        endAt: entry.endAt.toUtc(),
        flyerCount: entry.flyerCount?.toDouble(),
      ),
    ),
    map: (poi) => poi.toStandDetail(),
  );

  Future<StandDetailModel> updateStandEntry(String standId, StandEntryUpdateModel entry) => send(
    request: (api) => api.v1CampaignsPoisPoiIdEntriesEntryIdPut(
      poiId: standId,
      entryId: entry.entryId,
      body: UpdatePoiStandEntry(
        startAt: entry.startAt.toUtc(),
        endAt: entry.endAt.toUtc(),
        flyerCount: entry.flyerCount?.toDouble(),
      ),
    ),
    map: (poi) => poi.toStandDetail(),
  );

  Future<StandDetailModel> deleteStandEntry(String standId, String entryId) => send(
    request: (api) => api.v1CampaignsPoisPoiIdEntriesEntryIdDelete(poiId: standId, entryId: entryId),
    map: (poi) => poi.toStandDetail(),
  );
}
