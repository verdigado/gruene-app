import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

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

void switchCampaign(Campaign? campaign, BuildContext context) {
  var appSettings = GetIt.I<AppSettings>();
  appSettings.campaign.activeCampaign.recentSelectedCampaignId = campaign?.id;
  showSnackBar(context, t.campaigns.infoToast.campaigns_changed(campaignName: campaign?.name ?? t.common.notAvailable));
  GetIt.I<ActiveCampaignNotifier>().reset();
}
