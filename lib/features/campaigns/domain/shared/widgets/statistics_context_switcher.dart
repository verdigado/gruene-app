import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/campaign_select_dialog.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class StatisticsContextSwitcher extends StatefulWidget {
  final VoidCallback campaignChanged;
  final String? Function() getCurrentContextCampaignId;
  final void Function(String campaignId) setCurrentContextCampaignId;

  const StatisticsContextSwitcher({
    super.key,
    required this.campaignChanged,
    required this.getCurrentContextCampaignId,
    required this.setCurrentContextCampaignId,
  });

  @override
  State<StatisticsContextSwitcher> createState() => _StatisticsContextSwitcherState();
}

class _StatisticsContextSwitcherState extends State<StatisticsContextSwitcher> {
  String? _currentCampaignName;
  bool _isloading = true;
  int _loadRequestId = 0;
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
    _appSettings.campaign.activeCampaign.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final requestId = ++_loadRequestId;
    setState(() {
      _isloading = true;
    });

    var campaignService = GetIt.I<CampaignApiService>();
    String? currentCampaignId = widget.getCurrentContextCampaignId();
    var campaignName = switch (currentCampaignId) {
      null => t.common.unknown,
      CampaignConstants.allCampaignsId => t.campaigns.statistics.poi.allTime,
      _ => (await campaignService.getCampaign(currentCampaignId)).name,
    };

    // A newer load started while this one was in flight; drop this result
    if (!mounted || requestId != _loadRequestId) return;
    setState(() {
      _isloading = false;
      _currentCampaignName = campaignName;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _selectCampaign,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.campaigns.statistics.poi.statsForCampaign,
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
