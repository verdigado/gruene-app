import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_list_item_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_update_model.dart';
import 'package:gruene_app/app/services/api/base_poi_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class PosterApiService extends BasePoiApiService {
  PosterApiService() : super(poiType: PoiServiceType.poster);

  Future<PoiDetailModel> createNewPoster(PosterCreateModel newPoster) async {
    var poi = await send<Poi, Poi>(
      request: (api) => api.v1CampaignsPoisPost(
        body: CreatePoi(
          campaignId: newPoster.campaignId,
          coords: newPoster.location.toGeoJsonCoords(),
          type: poiType.toApiPoisType(),
          address: newPoster.address.toPoiAddress(),
        ),
      ),
    );
    if (newPoster.imageFileLocation != null) {
      poi = await storeNewPhoto(poi.id, newPoster.imageFileLocation!) ?? poi;
    }
    return poi.toMarkerItem();
  }

  Future<PoiDetailModel> updatePoster(PosterUpdateModel posterUpdate) async {
    final poi = await send<Poi, Poi>(
      request: (api) => api.v1CampaignsPoisPoiIdPut(
        poiId: posterUpdate.id,
        body: UpdatePoi(
          address: posterUpdate.address.toPoiAddress(),
          poster: PoiPoster(
            status: posterUpdate.status.toPoiPosterStatus(),
            comment: posterUpdate.comment.isEmpty ? null : posterUpdate.comment,
          ),
        ),
      ),
    );
    final poiWithPhotos = await updatePhotos(
      posterUpdate.id,
      deletedPhotoIds: posterUpdate.deletedPhotoIds,
      newImageFileLocations: posterUpdate.newPhotos.map((photo) => photo.imageUrl),
    );
    return (poiWithPhotos ?? poi).toMarkerItem();
  }

  Future<PosterDetailModel> getPoiAsPosterDetail(String poiId) async {
    return getPoi(poiId, (p) => p.toPosterDetail());
  }

  Future<PosterListItemModel> getPoiAsPosterListItem(String poiId) {
    return getPoi(poiId, (p) => p.toPosterListItem());
  }

  Future<List<PosterListItemModel>> getMyPosters(String campaignId) async => send(
    request: (api) => api.v1CampaignsPoisSelfGet(type: poiType.toApiPoisType(), campaignId: [campaignId]),
    map: (result) => result.data.where(filterByCutOffDate).map((p) => p.toPosterListItem()).toList(),
  );
}
