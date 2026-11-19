// TODO #1266: imports used by the commented-out flyer pin client
// import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/models/campaigns/flyer/flyer_create_model.dart';
import 'package:gruene_app/app/models/campaigns/flyer/flyer_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/flyer/flyer_update_model.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/services/api/base_poi_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/converters.dart';

// import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class FlyerApiService extends BasePoiApiService {
  FlyerApiService() : super(poiType: PoiServiceType.flyer);

  // TODO #1266: FLYER_SPOT is no longer a pin type (api#744), the flyer pin client is removed
  Future<PoiDetailModel> createNewFlyer(FlyerCreateModel newFlyer) async => throw UnimplementedError();
  // Future<PoiDetailModel> createNewFlyer(FlyerCreateModel newFlyer) async => send(
  //   request: (api) => api.v1CampaignsPoisPost(
  //     body: CreatePoi(
  //       campaignId: newFlyer.campaignId,
  //       coords: newFlyer.location.toGeoJsonCoords(),
  //       type: poiType.toApiPoisType(),
  //       address: newFlyer.address.toPoiAddress(),
  //       flyerSpot: PoiFlyerSpot(flyerCount: newFlyer.flyerCount.toDouble()),
  //     ),
  //   ),
  //   map: (result) => result.toMarkerItem(),
  // );

  // TODO #1266: FLYER_SPOT is no longer a pin type (api#744), the flyer pin client is removed
  Future<PoiDetailModel> updateFlyer(FlyerUpdateModel flyerUpdate) async => throw UnimplementedError();
  // Future<PoiDetailModel> updateFlyer(FlyerUpdateModel flyerUpdate) async => send(
  //   request: (api) => api.v1CampaignsPoisPoiIdPut(
  //     poiId: flyerUpdate.id,
  //     body: UpdatePoi(
  //       address: flyerUpdate.address.toPoiAddress(),
  //       flyerSpot: PoiFlyerSpot(flyerCount: flyerUpdate.flyerCount.toDouble()),
  //     ),
  //   ),
  //   map: (result) => result.toMarkerItem(),
  // );

  Future<FlyerDetailModel> getPoiAsFlyerDetail(String poiId) {
    return getPoi(poiId, (p) => p.toFlyerDetail());
  }
}
