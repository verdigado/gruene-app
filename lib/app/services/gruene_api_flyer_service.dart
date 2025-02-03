import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_service.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_create_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_update_model.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiFlyerService extends GrueneApiCampaignsService {
  GrueneApiFlyerService() : super(poiType: PoiServiceType.flyer);

  Future<MarkerItemModel> createNewFlyer(FlyerCreateModel newFlyer) async {
    final requestParam = CreatePoi(
      coords: newFlyer.location.transformToGeoJsonCoords(),
      type: poiType.transformToApiCreateType(),
      address: newFlyer.address.transformToPoiAddress(),
      flyerSpot: PoiFlyerSpot(
        flyerCount: newFlyer.flyerCount.toDouble(),
      ),
    );
    // saving POI
    final newPoiResponse = await grueneApi.v1CampaignsPoisPost(body: requestParam);

    return newPoiResponse.body!.transformToMarkerItem();
  }

  Future<FlyerDetailModel> getPoiAsFlyerDetail(String poiId) {
    return getPoi(poiId, (p) => p.transformPoiToFlyerDetail());
  }

  Future<MarkerItemModel> updateFlyer(FlyerUpdateModel flyerUpdate) async {
    var dtoUpdate = UpdatePoi(
      address: flyerUpdate.address.transformToPoiAddress(),
      flyerSpot: PoiFlyerSpot(
        flyerCount: flyerUpdate.flyerCount.toDouble(),
      ),
    );
    var updatePoiResponse = await grueneApi.v1CampaignsPoisPoiIdPut(poiId: flyerUpdate.id, body: dtoUpdate);

    return updatePoiResponse.body!.transformToMarkerItem();
  }
}
