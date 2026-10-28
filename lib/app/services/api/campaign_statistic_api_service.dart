import 'package:gruene_app/app/models/campaigns/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/app/models/campaigns/statistics/campaign_statistics_set.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CampaignStatisticApiService extends BaseApiService {
  CampaignStatisticApiService() : super();

  Future<CampaignStatisticsModel> getStatistics({required String? campaigndId}) async => send(
    request: (api) => api.v1CampaignsStatisticsGet(campaignId: campaigndId),
    map: (result) => result.asCampaignStatistics(),
  );
}

extension StatisticsParser on CampaignStatistics {
  CampaignStatisticsModel asCampaignStatistics() {
    return CampaignStatisticsModel(
      flyerStats: flyer.asStatisticsSet(),
      houseStats: house.asStatisticsSet(),
      posterStats: poster.asStatisticsSet(),
    );
  }
}

extension PoiStatisticsParser on PoiStatistics {
  CampaignStatisticsSet asStatisticsSet() {
    return CampaignStatisticsSet(
      own: own,
      subDivision: subDivision,
      division: division,
      state: state,
      germany: germany,
    );
  }
}
