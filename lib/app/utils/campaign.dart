import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';

String? getCurrentCampaignId() {
  var appSettings = GetIt.I<AppSettings>();
  return appSettings.campaign.activeCampaign.recentSelectedCampaignId;
}

String? getCurrentPoiStatisticsCampaignId() {
  var appSettings = GetIt.I<AppSettings>();
  var currentCampaignId =
      appSettings.campaign.recentPoiStatisticsCampaignId ??
      appSettings.campaign.activeCampaign.recentSelectedCampaignId;
  return currentCampaignId;
}

void switchCampaign(String? campaignId) {
  var appSettings = GetIt.I<AppSettings>();
  appSettings.campaign.activeCampaign.recentSelectedCampaignId = campaignId;
  GetIt.I<ActiveCampaignNotifier>().reset();
}
