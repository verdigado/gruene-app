import 'package:gruene_app/app/models/campaigns/route/route_assignment_update_model.dart';
import 'package:gruene_app/app/models/campaigns/route/route_status_update_model.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class RouteApiService extends BaseApiService {
  Future<Route> getRoute(String routeId) async =>
      send(request: (api) => api.v1CampaignsRoutesRouteIdGet(routeId: routeId));

  Future<void> updateRouteAssignemnt(RouteAssignmentUpdateModel route) => send(
    request: (api) => api.v1CampaignsRoutesRouteIdTeamPut(
      routeId: route.id,
      body: RouteAssignTeam(teamId: route.team?.id),
    ),
  );

  Future<void> updateRouteStatus(RouteStatusUpdateModel route) => send(
    request: (api) => api.v1CampaignsRoutesRouteIdStatusPut(
      routeId: route.id,
      body: UpdateRouteStatus(status: route.status.toUpdateRouteStatusStatus()),
    ),
  );
}
