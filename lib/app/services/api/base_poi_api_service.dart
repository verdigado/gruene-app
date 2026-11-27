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

/// A photo step of a change, done or given up.
enum PhotoStep {
  /// The photo with this id was deleted, or was gone already.
  deleted,

  /// The photo from this local file was uploaded.
  uploaded,

  /// The photo from this local file could not be uploaded, as the file is gone: the photo is lost.
  fileMissing,
}

/// Told about each photo step of a change, with the photo's id ([PhotoStep.deleted]) or its local file.
typedef OnPhotoStep = Future<void> Function(String photo, PhotoStep step);

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
  /// [onPhotoStep] is told once the photo is uploaded, before its file is deleted, so that the queue can drop the
  /// photo from its action: a retry of that action then does not upload it again.
  /// Returns null without uploading if the file does not exist, and tells [onPhotoStep] that the photo is lost.
  /// Any other error reading the file is thrown, so that the queued action is retried instead of losing the photo.
  Future<Poi?> storeNewPhoto(String poiId, String imageFileLocation, {OnPhotoStep? onPhotoStep}) async {
    final timeStamp = DateFormat('yyMMdd_HHmmss').format(DateTime.now());
    final fileManager = GetIt.I<FileManager>();
    final Uint8List photo;
    try {
      photo = await fileManager.retrieveFileData(imageFileLocation);
    } on PathNotFoundException catch (e) {
      logger.e('Photo $imageFileLocation of pin $poiId not uploaded, its file is gone: ${e.message}');
      await onPhotoStep?.call(imageFileLocation, PhotoStep.fileMissing);
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
    // the queue drops the photo before its file is deleted, so a missing file always means a lost photo
    await onPhotoStep?.call(imageFileLocation, PhotoStep.uploaded);
    try {
      await fileManager.deleteFile(imageFileLocation);
    } on FileSystemException catch (e, stackTrace) {
      // the photo is uploaded and out of the queue, so a file left behind is only a leftover
      logger.e('File of the uploaded photo $imageFileLocation not deleted', error: e, stackTrace: stackTrace);
    }
    return poi;
  }

  /// Deletes and uploads photos of a pin. Returns the pin after the last change, or null if nothing changed.
  /// [onPhotoStep] is told after each step, see [storeNewPhoto].
  Future<Poi?> updatePhotos(
    String poiId, {
    required Iterable<String> deletedPhotoIds,
    required Iterable<String> newImageFileLocations,
    OnPhotoStep? onPhotoStep,
  }) async {
    Poi? poi;
    for (final photoId in deletedPhotoIds) {
      try {
        poi = await send<Poi, Poi>(
          request: (api) => api.v1CampaignsPoisPoiIdPhotosPhotoIdDelete(poiId: poiId, photoId: photoId),
        );
      } on ApiException catch (e) {
        // the photo is gone already, e.g. deleted just before the app was closed and its step could be saved;
        // if the pin itself is gone, the upload or the next change fails with 404 instead
        if (e.statusCode != 404) rethrow;
      }
      await onPhotoStep?.call(photoId, PhotoStep.deleted);
    }
    for (final imageFileLocation in newImageFileLocations) {
      poi = await storeNewPhoto(poiId, imageFileLocation, onPhotoStep: onPhotoStep) ?? poi;
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
