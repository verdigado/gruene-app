import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
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

  Future<List<MarkerItemModel>> loadPoisInRegion(LatLng locationSW, LatLng locationNE) async {
    final getPoisType = poiType.transformToApiGetType();

    final getPoisResult = await grueneApi.v1CampaignsPoisGet(
      type: getPoisType,
      bbox: locationSW.transformToGeoJsonBBoxString(locationNE),
    );
    if (getPoisResult.error != null) debugPrint(getPoisResult.error!.toString());

    return getPoisResult.body!.data.map((p) => p.transformToMarkerItem()).toList();
  }

  Future<List<MapLayerModel>> loadFocusAreasInRegion(LatLng locationSW, LatLng locationNE) async {
    var transformToGeoJsonBBoxString = locationSW.transformToGeoJsonBBoxString(locationNE);
    final getPoisResult = await grueneApi.v1CampaignsFocusAreasGet(
      bbox: transformToGeoJsonBBoxString,
    );
    return getPoisResult.body!.data.map((layerItem) => layerItem.transformToMapLayer()).toList();
  }

  Future<T> getPoi<T>(String poiId, T Function(Poi) transform) async {
    final poiResponse = await grueneApi.v1CampaignsPoisPoiIdGet(poiId: poiId);
    return transform(poiResponse.body!);
  }

  Future<void> deletePoi(String poiId) async {
    // ignore: unused_local_variable
    final deletePoiResponse = await grueneApi.v1CampaignsPoisPoiIdDelete(poiId: poiId);
  }
}
