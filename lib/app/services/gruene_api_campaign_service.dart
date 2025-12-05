import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiCampaignService extends GrueneApiBaseService {
  GrueneApiCampaignService() : super();

  Future<List<Campaign>> findCampaigns() async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsCampaignsGet(), map: (result) => result.data);
}
