import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/features/campaigns/screens/campaign_select_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class StatisticsCampaignSwitcher extends StatefulWidget {
  final Future<dynamic> Function() campaignChanged;

  const StatisticsCampaignSwitcher({super.key, required this.campaignChanged});

  @override
  State<StatisticsCampaignSwitcher> createState() => _StatisticsCampaignSwitcherState();
}

class _StatisticsCampaignSwitcherState extends State<StatisticsCampaignSwitcher> {
  String? _currentCampaignName;
  bool _isloading = true;
  final _appSettings = GetIt.I<AppSettings>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _appSettings.campaign.activeCampaign.addListener(_loadData);
  }

  @override
  void dispose() {
    super.dispose();
    _appSettings.campaign.activeCampaign.removeListener(_loadData);
  }

  Future<void> _loadData() async {
    setState(() {
      _isloading = true;
    });

    var campaignService = GetIt.I<GrueneApiCampaignService>();
    String? currentCampaignId = getCurrentPoiStatisticsCampaignId();
    var campaignName = switch (currentCampaignId) {
      null => t.common.unknown,
      '-1' => t.campaigns.statistic.poi_statistics.all_time,
      _ => (await campaignService.getCampaign(currentCampaignId)).name,
    };

    setState(() {
      _isloading = false;
      _currentCampaignName = campaignName;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        _selectCampaign();
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Container(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 6),
          decoration: BoxDecoration(color: ThemeColors.background),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.campaigns.statistic.poi_statistics.stats_for_campaign,
                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                  ),
                  Text(
                    t.common.actions.change,
                    style: theme.textTheme.labelMedium!.apply(decoration: TextDecoration.underline, fontWeightDelta: 5),
                  ),
                ],
              ),
              _isloading
                  ? Center(child: CircularProgressIndicator())
                  : Row(children: [Text(_currentCampaignName ?? '', style: theme.textTheme.bodyMedium)]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectCampaign() async {
    var selectedCampaignId = await showCampaignSelectDialogForStatistics(context);
    if (selectedCampaignId != null) {
      var appSettings = GetIt.I<AppSettings>();
      appSettings.campaign.recentPoiStatisticsCampaignId = selectedCampaignId;
      _loadData();
      widget.campaignChanged();
    }
  }
}
