import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/models/campaigns/flyer/flyer_create_model.dart';
import 'package:gruene_app/app/models/campaigns/flyer/flyer_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/flyer/flyer_update_model.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/services/api/base_poi_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class FlyerApiService extends BasePoiApiService {
  FlyerApiService() : super(poiType: PoiServiceType.flyer);

  Future<PoiDetailModel> createNewFlyer(FlyerCreateModel newFlyer) async => send(
    request: (api) => api.v1CampaignsPoisPost(
      body: CreatePoi(
        campaignId: newFlyer.campaignId,
        coords: newFlyer.location.toGeoJsonCoords(),
        type: poiType.toApiPoisType(),
        address: newFlyer.address.toPoiAddress(),
        flyerSpot: PoiFlyerSpot(flyerCount: newFlyer.flyerCount.toDouble()),
      ),
    ),
    map: (result) => result.toMarkerItem(),
  );

  Future<PoiDetailModel> updateFlyer(FlyerUpdateModel flyerUpdate) async => send(
    request: (api) => api.v1CampaignsPoisPoiIdPut(
      poiId: flyerUpdate.id,
      body: UpdatePoi(
        address: flyerUpdate.address.toPoiAddress(),
        flyerSpot: PoiFlyerSpot(flyerCount: flyerUpdate.flyerCount.toDouble()),
      ),
    ),
    map: (result) => result.toMarkerItem(),
  );

  Future<FlyerDetailModel> getPoiAsFlyerDetail(String poiId) {
    return getPoi(poiId, (p) => p.toFlyerDetail());
  }
}
