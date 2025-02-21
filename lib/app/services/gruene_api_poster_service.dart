import 'package:chopper/chopper.dart' as chopper;
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_service.dart';
import 'package:gruene_app/features/campaigns/helper/file_cache_manager.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_list_item_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_update_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class GrueneApiPosterService extends GrueneApiCampaignsService {
  GrueneApiPosterService() : super(poiType: PoiServiceType.poster);

  Future<MarkerItemModel> createNewPoster(PosterCreateModel newPoster) async {
    final requestParam = CreatePoi(
      coords: newPoster.location.transformToGeoJsonCoords(),
      type: poiType.transformToApiCreateType(),
      address: newPoster.address.transformToPoiAddress(),
    );
    // saving POI
    var newPoiResponse = handleApiError(await grueneApi.v1CampaignsPoisPost(body: requestParam));

    if (newPoiResponse.error == null && newPoster.imageFileLocation != null) {
      // saving Photo along with POI
      var poiId = newPoiResponse.body!.id;
      newPoiResponse = handleApiError(await _storeNewPhoto(poiId, newPoster.imageFileLocation!));
    }

    return newPoiResponse.body!.transformToMarkerItem();
  }

  Future<MarkerItemModel> updatePoster(PosterUpdateModel posterUpdate) async {
    var dtoUpdate = UpdatePoi(
      address: posterUpdate.address.transformToPoiAddress(),
      poster: PoiPoster(
        status: posterUpdate.status.transformToPoiPosterStatus(),
        comment: posterUpdate.comment.isEmpty ? null : posterUpdate.comment,
      ),
    );
    var updatePoiResponse =
        handleApiError(await grueneApi.v1CampaignsPoisPoiIdPut(poiId: posterUpdate.id, body: dtoUpdate));

    for (var photoId in posterUpdate.deletedPhotoIds) {
      updatePoiResponse = handleApiError(
        await grueneApi.v1CampaignsPoisPoiIdPhotosPhotoIdDelete(
          poiId: posterUpdate.id,
          photoId: photoId,
        ),
      );
    }

    for (var newPhoto in posterUpdate.newPhotos) {
      updatePoiResponse = handleApiError(await _storeNewPhoto(posterUpdate.id, newPhoto.imageUrl));
    }

    return updatePoiResponse.body!.transformToMarkerItem();
  }

  Future<chopper.Response<Poi>> _storeNewPhoto(String poiId, String imageFileLocation) async {
    var timeStamp = DateFormat('yyMMdd_HHmmss').format(DateTime.now());
    var fileManager = GetIt.I<FileManager>();
    var photo = await fileManager.retrieveFileData(imageFileLocation);
    final savePoiPhotoResponse = handleApiError(
      await grueneApi.v1CampaignsPoisPoiIdPhotosPost(
        poiId: poiId,
        image: http.MultipartFile.fromBytes(
          'image',
          photo,
          filename: 'poi_${poiId}_$timeStamp.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      ),
    );
    fileManager.deleteFile(imageFileLocation);
    return savePoiPhotoResponse;
  }

  Future<PosterDetailModel> getPoiAsPosterDetail(String poiId) async {
    return getPoi(poiId, (p) => p.transformPoiToPosterDetail());
  }

  Future<PosterListItemModel> getPoiAsPosterListItem(String poiId) {
    return getPoi(poiId, (p) => p.transformToPosterListItem());
  }

  Future<List<PosterListItemModel>> getMyPosters() async => getFromApi(
        apiRequest: (api) => api.v1CampaignsPoisSelfGet(type: poiType.transformToApiSelfGetType()),
        map: (result) => result.data.map((p) => p.transformToPosterListItem()).toList(),
      );
}
