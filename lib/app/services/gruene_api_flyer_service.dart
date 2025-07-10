import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_base_service.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_create_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_update_model.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiFlyerService extends GrueneApiCampaignsPoiBaseService {
  GrueneApiFlyerService() : super(poiType: PoiServiceType.flyer);

  Future<MarkerItemModel> createNewFlyer(FlyerCreateModel newFlyer) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisPost(
      body: CreatePoi(
        coords: newFlyer.location.transformToGeoJsonCoords(),
        type: poiType.transformToApiCreateType(),
        address: newFlyer.address.transformToPoiAddress(),
        flyerSpot: PoiFlyerSpot(flyerCount: newFlyer.flyerCount.toDouble()),
      ),
    ),
    map: (result) => result.transformToMarkerItem(),
  );

  Future<MarkerItemModel> updateFlyer(FlyerUpdateModel flyerUpdate) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisPoiIdPut(
      poiId: flyerUpdate.id,
      body: UpdatePoi(
        address: flyerUpdate.address.transformToPoiAddress(),
        flyerSpot: PoiFlyerSpot(flyerCount: flyerUpdate.flyerCount.toDouble()),
      ),
    ),
    map: (result) => result.transformToMarkerItem(),
  );

  Future<FlyerDetailModel> getPoiAsFlyerDetail(String poiId) {
    return getPoi(poiId, (p) => p.transformPoiToFlyerDetail());
  }
}
