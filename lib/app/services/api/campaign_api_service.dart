import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CampaignApiService extends BaseApiService {
  Future<List<Campaign>> findCampaigns() async =>
      send(request: (api) => api.v1CampaignsCampaignsGet(), map: (result) => result.data);

  Future<Campaign> getCampaign(String campaignId) async =>
      send(request: (api) => api.v1CampaignsCampaignsCampaignIdGet(campaignId: campaignId));
}
