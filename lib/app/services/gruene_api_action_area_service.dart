import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/features/campaigns/models/action_area/action_area_assignment_update_model.dart';
import 'package:gruene_app/features/campaigns/models/action_area/action_area_status_update_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiActionAreaService extends GrueneApiBaseService {
  GrueneApiActionAreaService() : super();

  Future<Area> getActionArea(String actionAreaId) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsAreasAreaIdGet(areaId: actionAreaId));

  Future<void> updateActionAreaStatus(ActionAreaStatusUpdateModel actionArea) => getFromApi(
    apiRequest: (api) => api.v1CampaignsAreasAreaIdStatusPut(
      areaId: actionArea.id,
      body: UpdateAreaStatus(status: actionArea.status.asUpdateAreaStatusStatus()),
    ),
  );

  Future<void> updateActionAreaAssignemnt(ActionAreaAssignmentUpdateModel actionArea) => getFromApi(
    apiRequest: (api) => api.v1CampaignsAreasAreaIdTeamPut(
      areaId: actionArea.id,
      body: AreaAssignTeam(teamId: actionArea.team?.id),
    ),
  );
}
