import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CampaignSelectWidget extends StatefulWidget {
  final bool enforceSelect;
  static int showCounter = 0;

  const CampaignSelectWidget({super.key, this.enforceSelect = false});

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

    var selectedCampaignId = getCurrentCampaignId();

    var campaignService = GetIt.I<GrueneApiCampaignService>();
    var allCampaigns = await campaignService.findCampaigns();
    var activeCampaigns = allCampaigns.activeCampaigns();
    activeCampaigns.sort((a, b) => a.electionDate.compareTo(b.electionDate));

    var divisionKeys = activeCampaigns.groupBy((c) => c.divisionKey).keys.toList();
    var divisionService = GetIt.I<GrueneApiDivisionsService>();
    var activeCampaignDivisions = await divisionService.searchDivision(divisionKeys: divisionKeys);

    var previousCampaignName = widget.enforceSelect && selectedCampaignId != null
        ? allCampaigns.firstWhereOrNull((c) => c.id == selectedCampaignId)?.name ?? t.common.unknown
        : t.common.unknown;

    setState(() {
      _loading = false;
      _activeCampaigns = activeCampaigns;
      _activeCampaignDivisions = activeCampaignDivisions;
      _selectedCampaignId = selectedCampaignId;
      _previousCampaignName = previousCampaignName;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      height: 300,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.campaigns.select.title, style: theme.textTheme.titleLarge),
                DialogCloseButton(onClose: _closeAndSave),
              ],
            ),
            Text(
              widget.enforceSelect
                  ? t.campaigns.select.enforceSelectHint(previousCampaignName: _previousCampaignName)
                  : t.campaigns.select.hint,
              style: theme.textTheme.bodySmall,
            ),
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
                        child: Column(children: _activeCampaigns.map((c) => _getCampaignRadioTile(c, theme)).toList()),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _closeAndSave() {
    if (widget.enforceSelect && !_activeCampaigns.isCampaignActive(_selectedCampaignId)) {
      // Don't allow closing without selection if selection is enforced
      return;
    }
    var appSettings = GetIt.I<AppSettings>();
    appSettings.campaign.activeCampaign.recentSelectedCampaignId = _selectedCampaignId;
    GetIt.I<ActiveCampaignNotifier>().reset();

    Navigator.of(context).pop(true);
  }

  Widget _getCampaignRadioTile(Campaign c, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
      ),
      child: RadioListTile<String>(
        value: c.id,
        fillColor: WidgetStatePropertyAll(ThemeColors.primary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: theme.textTheme.labelLarge),
            Text(
              '${_activeCampaignDivisions.firstWhere((d) => d.divisionKey == c.divisionKey).shortName}, ${t.campaigns.select.electionDate}: ${c.electionDate.getAsLocalDateString()}',
              style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled),
            ),
          ],
        ),
        visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity, horizontal: VisualDensity.minimumDensity),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    var dialogResult = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding)),
        child: CampaignSelectWidget(enforceSelect: enforceSelect),
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
    );
    if (enforceSelect && (dialogResult == null || dialogResult == false)) {
      // If selection is enforced, we need to show the dialog again if the user dismissed it without selecting
      continue;
    }
    break;
  }
}

extension CampaignListExtension on List<Campaign> {
  List<Campaign> activeCampaigns() {
    return where((c) => c.status == CampaignStatus.active).toList();
  }

  bool isCampaignActive(String? campaignId) {
    if (campaignId == null) return false;
    return activeCampaigns().any((c) => c.id == campaignId);
  }
}
