import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/utils/file_cache_manager.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

abstract class BasePoiApiService extends BaseApiService {
  final PoiServiceType poiType;

  BasePoiApiService({required this.poiType});

  Future<List<PoiDetailModel>> loadPoisInRegion(String campaignId, LatLng locationSW, LatLng locationNE) async => send(
    request: (api) => api.v1CampaignsPoisGet(
      type: poiType.toApiPoisType(),
      bbox: locationSW.toGeoJsonBBoxString(locationNE),
      campaignId: [campaignId],
    ),
    map: (result) => result.data.where(filterByCutOffDate).map((p) => p.toMarkerItem()).toList(),
  );

  Future<List<FocusArea>> loadFocusAreasInRegion(String campaignId, LatLng locationSW, LatLng locationNE) async => send(
    request: (api) =>
        api.v1CampaignsFocusAreasGet(bbox: locationSW.toGeoJsonBBoxString(locationNE), campaignId: campaignId),
    map: (result) => result.data,
  );

  Future<FocusArea> loadFocusArea(String focusAreaId) async =>
      send(request: (api) => api.v1CampaignsFocusAreasFocusAreaIdGet(focusAreaId: focusAreaId));

  Future<List<PollingStation>> loadPollingStationsInRegion(
    String campaignId,
    LatLng locationSW,
    LatLng locationNE,
  ) async => send(
    request: (api) =>
        api.v1CampaignsPollingStationsGet(bbox: locationSW.toGeoJsonBBoxString(locationNE), campaignId: [campaignId]),
    map: (result) => result.data,
  );

  Future<List<Route>> loadRoutesInRegion(String campaignId, LatLng locationSW, LatLng locationNE) async => send(
    request: (api) => api.v1CampaignsRoutesGet(
      type: poiType.toRoutesApiGetTypes(),
      bbox: locationSW.toGeoJsonBBoxString(locationNE),
      campaignId: campaignId,
    ),
    map: (result) => result.data,
  );

  Future<List<ExperienceArea>> loadExperienceAreasInRegion(
    String campaignId,
    LatLng locationSW,
    LatLng locationNE,
  ) async => send(
    request: (api) =>
        api.v1CampaignsExperienceAreasGet(bbox: locationSW.toGeoJsonBBoxString(locationNE), campaignId: campaignId),
    map: (result) => result.data,
  );

  Future<List<Area>> loadActionAreasInRegion(String campaignId, LatLng locationSW, LatLng locationNE) async => send(
    request: (api) => api.v1CampaignsAreasGet(
      bbox: locationSW.toGeoJsonBBoxString(locationNE),
      type: poiType.toApiAreasGetTypes(),
      campaignId: campaignId,
    ),
    map: (result) => result.data,
  );

  Future<T> getPoi<T>(String poiId, T Function(Poi) transform) async => send(
    request: (api) => api.v1CampaignsPoisPoiIdGet(poiId: poiId),
    map: transform,
  );

  Future<void> deletePoi(String poiId) async => send(
    request: (api) => api.v1CampaignsPoisPoiIdDelete(poiId: poiId),
    map: (p) {},
  );

  /// Uploads a photo from a local file and deletes the file afterwards. Only posters and stands can have photos.
  ///
  /// Returns null without uploading if the file is gone: it was deleted after an earlier upload of a queued action
  /// that failed further on and is now retried, so uploading it again is neither possible nor wanted.
  Future<Poi?> storeNewPhoto(String poiId, String imageFileLocation) async {
    final timeStamp = DateFormat('yyMMdd_HHmmss').format(DateTime.now());
    final fileManager = GetIt.I<FileManager>();
    final Uint8List photo;
    try {
      photo = await fileManager.retrieveFileData(imageFileLocation);
    } on FileSystemException catch (e) {
      logger.w('Photo $imageFileLocation of pin $poiId not uploaded, its file is gone: ${e.message}');
      return null;
    }
    final poi = await send<Poi, Poi>(
      request: (api) => api.v1CampaignsPoisPoiIdPhotosPost(
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
    return poi;
  }

  /// Deletes and uploads photos of a pin. Returns the pin after the last change, or null if nothing changed.
  Future<Poi?> updatePhotos(
    String poiId, {
    required Iterable<String> deletedPhotoIds,
    required Iterable<String> newImageFileLocations,
  }) async {
    Poi? poi;
    for (final photoId in deletedPhotoIds) {
      poi = await send<Poi, Poi>(
        request: (api) => api.v1CampaignsPoisPoiIdPhotosPhotoIdDelete(poiId: poiId, photoId: photoId),
      );
    }
    for (final imageFileLocation in newImageFileLocations) {
      poi = await storeNewPhoto(poiId, imageFileLocation) ?? poi;
    }
    return poi;
  }

  bool filterByCutOffDate(Poi poi) {
    if (Config.poiFilterCutOffDate == null) return true;

    if (poi.createdAt.millisecondsSinceEpoch > Config.poiFilterCutOffDate!.millisecondsSinceEpoch) return true;

    if (poi.type == PoiType.poster && poi.poster!.status == PosterStatus.ok) {
      return true;
    }

    return false;
  }
}
