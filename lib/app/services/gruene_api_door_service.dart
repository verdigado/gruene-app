import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_base_service.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_create_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_update_model.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiDoorService extends GrueneApiCampaignsPoiBaseService {
  GrueneApiDoorService() : super(poiType: PoiServiceType.door);

  Future<MarkerItemModel> createNewDoor(DoorCreateModel newDoor) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisPost(
      body: CreatePoi(
        coords: newDoor.location.transformToGeoJsonCoords(),
        type: poiType.transformToApiCreateType(),
        address: newDoor.address.transformToPoiAddress(),
        house: PoiHouse(
          countOpenedDoors: newDoor.openedDoors.toDouble(),
          countClosedDoors: newDoor.closedDoors.toDouble(),
        ),
      ),
    ),
    map: (result) => result.transformToMarkerItem(),
  );

  Future<MarkerItemModel> updateDoor(DoorUpdateModel doorUpdate) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsPoisPoiIdPut(
      poiId: doorUpdate.id,
      body: UpdatePoi(
        address: doorUpdate.address.transformToPoiAddress(),
        house: PoiHouse(
          countOpenedDoors: doorUpdate.openedDoors.toDouble(),
          countClosedDoors: doorUpdate.closedDoors.toDouble(),
        ),
      ),
    ),
    map: (result) => result.transformToMarkerItem(),
  );

  Future<DoorDetailModel> getPoiAsDoorDetail(String poiId) {
    return getPoi(poiId, (p) => p.transformPoiToDoorDetail());
  }
}
