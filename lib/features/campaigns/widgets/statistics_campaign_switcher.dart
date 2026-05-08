import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class StatisticsCampaignSwitcher extends StatefulWidget {
  const StatisticsCampaignSwitcher({super.key});

  @override
  State<StatisticsCampaignSwitcher> createState() => _StatisticsCampaignSwitcherState();
}

class _StatisticsCampaignSwitcherState extends State<StatisticsCampaignSwitcher> {
  String? _currentCampaignName;

  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isloading = true;
    });

    var campaignService = GetIt.I<GrueneApiCampaignService>();
    String? currentCampaignId = getCurrentPoiStatisticsCampaignId();
    var campaignName = currentCampaignId == null
        ? t.campaigns.statistic.poi_statistics.all_time
        : (await campaignService.getCampaign(currentCampaignId)).name;

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
    );
  }

  void _selectCampaign() {}
}
