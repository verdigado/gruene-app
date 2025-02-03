import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_service.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_create_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_update_model.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiDoorService extends GrueneApiCampaignsService {
  GrueneApiDoorService() : super(poiType: PoiServiceType.door);

  Future<MarkerItemModel> createNewDoor(DoorCreateModel newDoor) async {
    final requestParam = CreatePoi(
      coords: newDoor.location.transformToGeoJsonCoords(),
      type: poiType.transformToApiCreateType(),
      address: newDoor.address.transformToPoiAddress(),
      house: PoiHouse(
        countOpenedDoors: newDoor.openedDoors.toDouble(),
        countClosedDoors: newDoor.closedDoors.toDouble(),
      ),
    );
    // saving POI
    final newPoiResponse = await grueneApi.v1CampaignsPoisPost(body: requestParam);

    return newPoiResponse.body!.transformToMarkerItem();
  }

  Future<MarkerItemModel> updateDoor(DoorUpdateModel doorUpdate) async {
    var dtoUpdate = UpdatePoi(
      address: doorUpdate.address.transformToPoiAddress(),
      house: PoiHouse(
        countOpenedDoors: doorUpdate.openedDoors.toDouble(),
        countClosedDoors: doorUpdate.closedDoors.toDouble(),
      ),
    );
    var updatePoiResponse = await grueneApi.v1CampaignsPoisPoiIdPut(poiId: doorUpdate.id, body: dtoUpdate);

    return updatePoiResponse.body!.transformToMarkerItem();
  }

  Future<DoorDetailModel> getPoiAsDoorDetail(String poiId) {
    return getPoi(poiId, (p) => p.transformPoiToDoorDetail());
  }
}
