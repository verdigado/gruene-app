import 'package:get_it/get_it.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_set.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiCampaignsStatisticsService {
  late GrueneApi grueneApi;

  GrueneApiCampaignsStatisticsService() {
    grueneApi = GetIt.I<GrueneApi>();
  }

  Future<CampaignStatisticsModel> getStatistics() async {
    var statResult = await grueneApi.v1CampaignsStatisticsGet();
    return statResult.body!.asCampaignStatistics();
  }
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
      division: division,
      state: state,
      germany: germany,
    );
  }
}
