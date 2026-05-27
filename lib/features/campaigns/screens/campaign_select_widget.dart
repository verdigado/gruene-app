import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CampaignSelectWidget extends StatefulWidget {
  final CampaignSelectMode mode;
  static int showCounter = 0;

  const CampaignSelectWidget({super.key, this.mode = CampaignSelectMode.normal});

  @override
  State<CampaignSelectWidget> createState() => _CampaignSelectWidgetState();
}

class _CampaignSelectWidgetState extends State<CampaignSelectWidget> {
  String? _selectedCampaignId;
  bool _loading = true;
  List<Campaign> _activeCampaigns = [];
  List<Division> _activeCampaignDivisions = [];
  String _previousCampaignName = t.common.unknown;

  @override
  void initState() {
    super.initState();
    CampaignSelectWidget.showCounter++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  dispose() {
    super.dispose();
    CampaignSelectWidget.showCounter--;
  }

  void _loadData() async {
    setState(() => _loading = true);

    var selectedCampaignId = switch (widget.mode) {
      CampaignSelectMode.normal || CampaignSelectMode.enforceSelect => getCurrentCampaignId(),
      CampaignSelectMode.statistics => getCurrentPoiStatisticsCampaignId(),
    };

    var campaignService = GetIt.I<GrueneApiCampaignService>();
    var allCampaigns = await campaignService.findCampaigns();
    var selectableCampaigns = switch (widget.mode) {
      CampaignSelectMode.normal || CampaignSelectMode.enforceSelect => allCampaigns.activeCampaigns(),
      CampaignSelectMode.statistics => allCampaigns.activeAndClosedCampaigns(),
    };
    selectableCampaigns.sort((a, b) => a.electionDate.compareTo(b.electionDate));

    var divisionKeys = selectableCampaigns.groupBy((c) => c.divisionKey).keys.toList();
    var divisionService = GetIt.I<GrueneApiDivisionsService>();
    var activeCampaignDivisions = await divisionService.searchDivision(divisionKeys: divisionKeys);

    var previousCampaignName = widget.mode == CampaignSelectMode.enforceSelect && selectedCampaignId != null
        ? allCampaigns.firstWhereOrNull((c) => c.id == selectedCampaignId)?.name ?? t.common.unknown
        : t.common.unknown;

    setState(() {
      _loading = false;
      _activeCampaigns = selectableCampaigns;
      _activeCampaignDivisions = activeCampaignDivisions;
      _selectedCampaignId = selectedCampaignId;
      _previousCampaignName = previousCampaignName;
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleText = '', hintText = '', height = 300.0;

    switch (widget.mode) {
      case CampaignSelectMode.normal:
        titleText = t.campaigns.select.title;
        hintText = t.campaigns.select.hint;
        break;
      case CampaignSelectMode.enforceSelect:
        titleText = t.campaigns.select.title;
        hintText = t.campaigns.select.enforceSelectHint(previousCampaignName: _previousCampaignName);
        break;
      case CampaignSelectMode.statistics:
        titleText = t.campaigns.select.statisticsTitle;
        hintText = t.campaigns.select.statisticsHint;
        height = 450;
        break;
    }

    var theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titleText, style: theme.textTheme.titleLarge),
                DialogCloseButton(onClose: _closeAndSave),
              ],
            ),
            Text(hintText, style: theme.textTheme.bodySmall),
            SizedBox(height: 16),
            _loading
                ? Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      child: RadioGroup(
                        groupValue: _selectedCampaignId,
                        onChanged: (value) => setState(() {
                          _selectedCampaignId = value!;
                        }),
                        child: Column(
                          children: [
                            widget.mode == CampaignSelectMode.statistics
                                ? _getCampaignRadioTile(null, theme)
                                : SizedBox.shrink(),
                            ..._activeCampaigns.map((c) => _getCampaignRadioTile(c, theme)),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _closeAndSave() {
    if (widget.mode == CampaignSelectMode.enforceSelect && !_activeCampaigns.isCampaignActive(_selectedCampaignId)) {
      // Don't allow closing without selection if selection is enforced
      return;
    }
    Navigator.of(context).pop(_selectedCampaignId);
  }

  Widget _getCampaignRadioTile(Campaign? campaign, ThemeData theme) {
    var campaignId = '-1',
        campaignName = t.campaigns.statistic.poi_statistics.all_time,
        campaignSubtitle = t.campaigns.statistic.poi_statistics.all_time_subtitle;

    if (campaign != null) {
      campaignId = campaign.id;
      campaignName = campaign.name;
      campaignSubtitle =
          '${_activeCampaignDivisions.firstWhere((d) => d.divisionKey == campaign.divisionKey).shortName}, ${t.campaigns.select.electionDate}: ${campaign.electionDate.getAsLocalDateString()}';
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
      ),
      padding: EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCampaignId = campaignId;
          });
        },
        child: Row(
          children: [
            Radio<String>(
              value: campaignId,
              fillColor: WidgetStatePropertyAll(ThemeColors.primary),
              visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              splashRadius: 0,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(campaignName, style: theme.textTheme.labelLarge),
                Text(campaignSubtitle, style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled)),
              ],
            ),
            // ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCampaignSelectDialog(BuildContext context, {bool enforceSelect = false}) async {
  if (CampaignSelectWidget.showCounter > 0) {
    // Prevent multiple dialogs from being opened at the same time
    return;
  }

  var isDismissible = !enforceSelect;

  final theme = Theme.of(context);
  while (true) {
    var selectCampaignResult = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding)),
        child: CampaignSelectWidget(mode: enforceSelect ? CampaignSelectMode.enforceSelect : CampaignSelectMode.normal),
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
    );
    if (enforceSelect && selectCampaignResult == null) {
      // If selection is enforced, we need to show the dialog again if the user dismissed it without selecting
      continue;
    }

    // apply selection
    switchCampaign(selectCampaignResult);

    break;
  }
}

Future<String?> showCampaignSelectDialogForStatistics(BuildContext context) async {
  final theme = Theme.of(context);
  var selectCampaignResult = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding)),
      child: CampaignSelectWidget(mode: CampaignSelectMode.statistics),
    ),
    isScrollControlled: true,
    isDismissible: true,
    useRootNavigator: true,
    backgroundColor: theme.colorScheme.surface,
  );
  return selectCampaignResult;
}
