import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/features/campaigns/models/route/route_update_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiRouteService extends GrueneApiBaseService {
  GrueneApiRouteService() : super();

  Future<Route> getRoute(String routeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsRoutesRouteIdGet(routeId: routeId),
    map: (result) => result,
  );

  Future<void> updateRoute(RouteUpdateModel route) => getFromApi(
    apiRequest: (api) => api.v1CampaignsRoutesRouteIdPut(
      routeId: route.id,
      body: UpdateRoute(
        name: route.routeDetail.name,
        type: route.routeDetail.type.asUpdateRouteType(),
        status: route.status.asUpdateRouteStatus(),
        lineString: route.routeDetail.lineString,
      ),
    ),
    map: (result) => result,
  );
}
