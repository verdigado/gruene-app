import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiRouteService extends GrueneApiBaseService {
  GrueneApiRouteService() : super();

  Future<Route> getRoute(String routeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsRoutesRouteIdGet(routeId: routeId),
    map: (result) => result,
  );
}
