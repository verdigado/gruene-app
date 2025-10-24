import 'dart:async';

import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

abstract class GrueneApiCampaignsPoiBaseService extends GrueneApiBaseService {
  final PoiServiceType poiType;

  GrueneApiCampaignsPoiBaseService({required this.poiType}) : super();

  Future<List<MarkerItemModel>> loadPoisInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisGet(
      type: poiType.transformToApiGetType(),
      bbox: locationSW.transformToGeoJsonBBoxString(locationNE),
    ),
    map: (result) => result.data.where(filterByCutOffDate).map((p) => p.transformToMarkerItem()).toList(),
  );

  Future<List<FocusArea>> loadFocusAreasInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsFocusAreasGet(bbox: locationSW.transformToGeoJsonBBoxString(locationNE)),
    map: (result) => result.data,
  );

  Future<List<PollingStation>> loadPollingStationsInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPollingStationsGet(bbox: locationSW.transformToGeoJsonBBoxString(locationNE)),
    map: (result) => result.data,
  );

  Future<List<Route>> loadRoutesInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsRoutesGet(
      type: poiType.transformToRoutesApiGetType(),
      bbox: locationSW.transformToGeoJsonBBoxString(locationNE),
    ),
    map: (result) => result.data,
  );

  Future<List<ExperienceArea>> loadExperienceAreasInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsExperienceAreasGet(bbox: locationSW.transformToGeoJsonBBoxString(locationNE)),
    map: (result) => result.data,
  );

  Future<List<Area>> loadActionAreasInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsAreasGet(bbox: locationSW.transformToGeoJsonBBoxString(locationNE)),
    map: (result) => result.data,
  );

  Future<T> getPoi<T>(String poiId, T Function(Poi) transform) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisPoiIdGet(poiId: poiId),
    map: transform,
  );

  Future<void> deletePoi(String poiId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisPoiIdDelete(poiId: poiId),
    map: (p) {},
  );

  bool filterByCutOffDate(Poi poi) {
    if (Config.poiFilterCutOffDate == null) return true;

    if (poi.createdAt.millisecondsSinceEpoch > Config.poiFilterCutOffDate!.millisecondsSinceEpoch) return true;

    if (poi.type == PoiType.poster && poi.poster!.status == PoiPosterStatus.ok) {
      return true;
    }

    return false;
  }
}
