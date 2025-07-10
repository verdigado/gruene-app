import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiRouteService extends GrueneApiCampaignsService {
  GrueneApiRouteService() : super(poiType: PoiServiceType.flyer);

  Future<Route> getRoute(String routeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsRoutesRouteIdGet(routeId: routeId),
    map: (result) => result,
  );
}
