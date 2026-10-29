import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/api/division_api_service.dart';
import 'package:gruene_app/app/services/api/profile_api_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/utils/extensions.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
import 'package:gruene_app/app/widgets/icon.dart';
import 'package:gruene_app/features/campaigns/core/converters.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CampaignSelectWidget extends StatefulWidget {
  final CampaignSelectMode mode;
  final bool storeRecentSeenCampaigns;
  static int showCounter = 0;
  final String? Function()? getCurrentContextCampaignId;

  const CampaignSelectWidget({
    super.key,
    this.mode = CampaignSelectMode.normal,
    this.storeRecentSeenCampaigns = false,
    this.getCurrentContextCampaignId,
  }) : assert(
         mode != CampaignSelectMode.statistics || getCurrentContextCampaignId != null,
         'getCurrentContextCampaignId must be provided when mode is CampaignSelectMode.statistics',
       );

  @override
  State<CampaignSelectWidget> createState() => _CampaignSelectWidgetState();
}

class _CampaignSelectWidgetState extends State<CampaignSelectWidget> {
  String? _selectedCampaignId;
  bool _loading = true;
  List<Campaign> _activeCampaigns = [];
  List<Division> _activeCampaignDivisions = [];
  String _previousCampaignName = t.common.unknown;
  List<String> _previouslySeenCampaignIds = [];

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
    CampaignSelectWidget.showCounter--;
    super.dispose();
  }

  void _loadData() async {
    setState(() => _loading = true);

    var selectedCampaignId = switch (widget.mode) {
      CampaignSelectMode.normal || CampaignSelectMode.enforceSelect => getCurrentCampaignId(),
      CampaignSelectMode.statistics => widget.getCurrentContextCampaignId?.call(),
    };

    var campaignService = GetIt.I<CampaignApiService>();
    var allCampaigns = await campaignService.findCampaigns();
    var selectableCampaigns = switch (widget.mode) {
      CampaignSelectMode.normal || CampaignSelectMode.enforceSelect => allCampaigns.activeCampaigns(),
      CampaignSelectMode.statistics => allCampaigns.activeAndClosedCampaigns(),
    };
    selectableCampaigns.sort((a, b) => a.electionDate.compareTo(b.electionDate));

    var divisionKeys = selectableCampaigns.groupBy((c) => c.divisionKey).keys.toList();
    var divisionService = GetIt.I<DivisionApiService>();
    var activeCampaignDivisions = await divisionService.getDivisions(divisionKeys: divisionKeys);

    var previousCampaignName = widget.mode == CampaignSelectMode.enforceSelect && selectedCampaignId != null
        ? allCampaigns.firstWhereOrNull((c) => c.id == selectedCampaignId)?.name ?? t.common.unknown
        : t.common.unknown;

    if (widget.mode == CampaignSelectMode.enforceSelect &&
        selectedCampaignId == null &&
        selectableCampaigns.isNotEmpty) {
      var profileService = GetIt.I<ProfileApiService>();
      var currentProfile = await profileService.getSelf();
      var userDivisionKeys = (currentProfile.memberships).map((m) => m.division.divisionKey).toList();
      var preSelectCandidates = selectableCampaigns
          .where((c) => userDivisionKeys.any((d) => d.startsWith(c.divisionKey.stripRight('0'))))
          .map((c) => c.id)
          .toList();
      if (preSelectCandidates.length == 1) {
        selectedCampaignId = preSelectCandidates.first;
      }
    }

    var recentCampaigns = selectableCampaigns.map((c) => c.id).toList();
    var previouslySeenCampaignIds = recentCampaigns;
    if (widget.storeRecentSeenCampaigns) {
      var appSettings = GetIt.I<AppSettings>();
      previouslySeenCampaignIds = appSettings.campaign.activeCampaign.recentlySeenCampaignIds ?? [];

      appSettings.campaign.activeCampaign.recentlySeenCampaignIds = recentCampaigns;
      GetIt.I<NewCampaignNotifier>().reset();
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _activeCampaigns = selectableCampaigns;
      _activeCampaignDivisions = activeCampaignDivisions;
      _selectedCampaignId = selectedCampaignId;
      _previousCampaignName = previousCampaignName;
      _previouslySeenCampaignIds = previouslySeenCampaignIds;
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
            Container(
              height: 45,
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                spacing: 8,
                crossAxisAlignment: .center,
                children: [
                  CustomIcon(path: 'assets/icons/chat_info.svg', color: ThemeColors.primary),

                  GestureDetector(
                    onTap: () {
                      logger.i('START');
                      var url = Config.requestCampaignUrl;
                      openUrl(url, context);
                    },

                    child: Text(
                      t.campaigns.select.reportMissingCampaign,
                      style: theme.textTheme.labelLarge?.apply(
                        color: ThemeColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
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
    var selectedCampaign = _selectedCampaignId == CampaignConstants.allCampaignsId
        ? Campaign(
            id: CampaignConstants.allCampaignsId,
            scope: .federal,
            type: .election,
            status: .active,
            name: '',
            divisionKey: '',
            electionDate: DateTime.now(),
          )
        : _activeCampaigns.firstWhere((c) => c.id == _selectedCampaignId);
    Navigator.of(context).pop(CampaignSelectResult.success(selectedCampaign));
  }

  Widget _getCampaignRadioTile(Campaign? campaign, ThemeData theme) {
    var campaignId = CampaignConstants.allCampaignsId,
        campaignName = t.campaigns.statistic.poi_statistics.all_time,
        campaignSubtitle = t.campaigns.statistic.poi_statistics.all_time_subtitle;

    if (campaign != null) {
      campaignId = campaign.id;
      campaignName = campaign.name;
      campaignSubtitle =
          '${_activeCampaignDivisions.firstWhere((d) => d.divisionKey == campaign.divisionKey).shortName}, ${t.campaigns.select.electionDate}: ${campaign.electionDate.toLocalDateString()}';
    }

    Widget asBadge(bool doBadge, Widget child) => doBadge
        ? Badge(
            child: Container(padding: EdgeInsets.only(right: 8), child: child),
          )
        : child;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  asBadge(
                    campaignId != CampaignConstants.allCampaignsId && !_previouslySeenCampaignIds.contains(campaignId),
                    Text(campaignName, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelLarge),
                  ),
                  Text(
                    campaignSubtitle,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled),
                  ),
                ],
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }
}

class CampaignSelectResult {
  final Campaign? campaign;
  final bool success;

  CampaignSelectResult(this.success, this.campaign);

  factory CampaignSelectResult.success(Campaign? campaign) {
    return CampaignSelectResult(true, campaign);
  }

  factory CampaignSelectResult.fail() {
    return CampaignSelectResult(false, null);
  }
}
