import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/campaign_select_dialog.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class StatisticsCampaignSwitcher extends StatefulWidget {
  final VoidCallback campaignChanged;
  final String? Function() getCurrentContextCampaignId;
  final Future<void> Function(String campaignId) setCurrentContextCampaignId;

  const StatisticsCampaignSwitcher({
    super.key,
    required this.campaignChanged,
    required this.getCurrentContextCampaignId,
    required this.setCurrentContextCampaignId,
  });

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
    String? currentCampaignId = await widget.getCurrentContextCampaignId();
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
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentCampaignName ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Future<void> _selectCampaign() async {
    var selectedCampaignId = await showCampaignSelectDialogForStatistics(context, widget.getCurrentContextCampaignId);
    if (selectedCampaignId != null) {
      widget.setCurrentContextCampaignId(selectedCampaignId);
      _loadData();
      widget.campaignChanged();
    }
  }
}
