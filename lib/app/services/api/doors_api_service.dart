import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_create_model.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_update_model.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/api/pois_api_base_service.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class DoorsApiService extends PoisApiBaseService {
  DoorsApiService() : super(poiType: PoiServiceType.door);

  Future<PoiDetailModel> createNewDoor(DoorCreateModel newDoor) async => send(
    request: (api) => api.v1CampaignsPoisPost(
      body: CreatePoi(
        campaignId: newDoor.campaignId,
        coords: newDoor.location.toGeoJsonCoords(),
        type: poiType.toApiPoisType(),
        address: newDoor.address.toPoiAddress(),
        house: PoiHouse(
          countOpenedDoors: newDoor.openedDoors.toDouble(),
          countClosedDoors: newDoor.closedDoors.toDouble(),
        ),
      ),
    ),
    map: (result) => result.toMarkerItem(),
  );

  Future<PoiDetailModel> updateDoor(DoorUpdateModel doorUpdate) async => send(
    request: (api) => api.v1CampaignsPoisPoiIdPut(
      poiId: doorUpdate.id,
      body: UpdatePoi(
        address: doorUpdate.address.toPoiAddress(),
        house: PoiHouse(
          countOpenedDoors: doorUpdate.openedDoors.toDouble(),
          countClosedDoors: doorUpdate.closedDoors.toDouble(),
        ),
      ),
    ),
    map: (result) => result.toMarkerItem(),
  );

  Future<DoorDetailModel> getPoiAsDoorDetail(String poiId) {
    return getPoi(poiId, (p) => p.toDoorDetail());
  }
}
