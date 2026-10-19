import 'package:gruene_app/app/models/campaigns/statistics/campaign_statistics_set.dart';

class CampaignStatisticsModel {
  final CampaignStatisticsSet flyerStats, houseStats, posterStats;

  const CampaignStatisticsModel({required this.flyerStats, required this.houseStats, required this.posterStats});
}
