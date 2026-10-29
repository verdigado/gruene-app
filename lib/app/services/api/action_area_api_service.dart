import 'package:gruene_app/app/models/campaigns/action_area/action_area_assignment_update_model.dart';
import 'package:gruene_app/app/models/campaigns/action_area/action_area_status_update_model.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ActionAreaApiService extends BaseApiService {
  Future<Area> getActionArea(String actionAreaId) async =>
      send(request: (api) => api.v1CampaignsAreasAreaIdGet(areaId: actionAreaId));

  Future<void> updateActionAreaStatus(ActionAreaStatusUpdateModel actionArea) => send(
    request: (api) => api.v1CampaignsAreasAreaIdStatusPut(
      areaId: actionArea.id,
      body: UpdateAreaStatus(status: actionArea.status.toUpdateAreaStatusStatus()),
    ),
  );

  Future<void> updateActionAreaAssignemnt(ActionAreaAssignmentUpdateModel actionArea) => send(
    request: (api) => api.v1CampaignsAreasAreaIdTeamPut(
      areaId: actionArea.id,
      body: AreaAssignTeam(teamId: actionArea.team?.id),
    ),
  );
}
