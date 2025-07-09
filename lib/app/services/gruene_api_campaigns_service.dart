import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/features/campaigns/models/map_layer_model.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

abstract class GrueneApiCampaignsService {
  late GrueneApi grueneApi;

  final PoiServiceType poiType;

  GrueneApiCampaignsService({required this.poiType}) {
    grueneApi = GetIt.I<GrueneApi>();
  }

  Future<List<MarkerItemModel>> loadPoisInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisGet(
      type: poiType.transformToApiGetType(),
      bbox: locationSW.transformToGeoJsonBBoxString(locationNE),
    ),
    map: (result) => result.data.where(filterByCutOffDate).map((p) => p.transformToMarkerItem()).toList(),
  );

  Future<List<MapLayerModel>> loadFocusAreasInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsFocusAreasGet(bbox: locationSW.transformToGeoJsonBBoxString(locationNE)),
    map: (result) => result.data.map((layerItem) => layerItem.transformToMapLayer()).toList(),
  );

  Future<List<PollingStation>> loadPollingStationsInRegion(LatLng locationSW, LatLng locationNE) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPollingStationsGet(bbox: locationSW.transformToGeoJsonBBoxString(locationNE)),
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

  Future<T> getFromApi<S, T>({
    required Future<Response<S>> Function(GrueneApi api) apiRequest,
    required T Function(S data) map,
  }) async {
    final response = await apiRequest(grueneApi);

    handleApiError(response);

    final body = response.body as S;
    return map(body);
  }

  Response<T> handleApiError<T>(Response<T> response) {
    if (!response.isSuccessful || response.body == null) {
      throw ApiException(statusCode: response.statusCode);
    }
    return response;
  }

  bool filterByCutOffDate(Poi poi) {
    if (Config.poiFilterCutOffDate == null) return true;

    if (poi.createdAt.millisecondsSinceEpoch > Config.poiFilterCutOffDate!.millisecondsSinceEpoch) return true;

    if (poi.type == PoiType.poster && poi.poster!.status == PoiPosterStatus.ok) {
      return true;
    }

    return false;
  }
}

class ApiException implements Exception {
  int statusCode;
  ApiException({required this.statusCode});
}
