import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
// TODO decouple from campaigns feature: app layer should not depend on AppTimers, e.g. let the feature subscribe to navigation events instead
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

String? getCurrentCampaignId() {
  var appSettings = GetIt.I<AppSettings>();
  return appSettings.campaign.activeCampaign.recentSelectedCampaignId;
}

String? getCurrentPoiStatisticsCampaignId() =>
    _getStatisticsCampaignId(GetIt.I<AppSettings>().campaign.recentPoiStatisticsCampaignId);

String? getCurrentTeamMembershipStatisticsCampaignId() =>
    _getStatisticsCampaignId(GetIt.I<AppSettings>().campaign.recentTeamMembershipStatisticsCampaignId);

/// Returns the campaign chosen for a statistics view, falling back to the active campaign
String? _getStatisticsCampaignId(String? statisticsCampaignId) => statisticsCampaignId ?? getCurrentCampaignId();

void switchCampaign(Campaign? campaign, BuildContext context) {
  var appSettings = GetIt.I<AppSettings>();
  appSettings.campaign.activeCampaign.recentSelectedCampaignId = campaign?.id;
  showSnackBar(
    context: context,
    text: t.campaigns.infoToast.campaigns_changed(campaignName: campaign?.name ?? t.common.notAvailable),
  );
  GetIt.I<ActiveCampaignNotifier>().reset();
}
