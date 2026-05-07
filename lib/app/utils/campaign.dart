import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/utils/app_settings.dart';

String? getCurrentCampaignId() {
  var appSettings = GetIt.I<AppSettings>();
  return appSettings.campaign.activeCampaign.recentSelectedCampaignId;
}
