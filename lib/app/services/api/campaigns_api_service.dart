import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CampaignsApiService extends BaseApiService {
  CampaignsApiService() : super();

  Future<List<Campaign>> findCampaigns() async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsCampaignsGet(), map: (result) => result.data);

  Future<Campaign> getCampaign(String campaignId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsCampaignsCampaignIdGet(campaignId: campaignId),
    map: (result) => result,
  );
}
