import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CampaignSelectWidget extends StatefulWidget {
  const CampaignSelectWidget({super.key});

  @override
  State<CampaignSelectWidget> createState() => _CampaignSelectWidgetState();
}

class _CampaignSelectWidgetState extends State<CampaignSelectWidget> {
  String? _selectedCampaignId;
  bool _loading = true;
  List<Campaign> _activeCampaigns = [];
  List<Division> _activeCampaignDivisions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    var campaignService = GetIt.I<GrueneApiCampaignService>();
    var allCampaigns = await campaignService.findCampaigns();

    var activeCampaigns = allCampaigns.where((c) => c.status == CampaignStatus.active).toList();
    activeCampaigns.sort((a, b) => a.electionDate.compareTo(b.electionDate));

    var divisionKeys = activeCampaigns.groupBy((c) => c.divisionKey).keys.toList();
    var divisionService = GetIt.I<GrueneApiDivisionsService>();
    var activeCampaignDivisions = await divisionService.searchDivision(divisionKeys: divisionKeys);

    var appSettings = GetIt.I<AppSettings>();
    var selectedCampaignId = appSettings.campaign.activeCampaign.recentSelectedCampaignId;

    setState(() {
      _loading = false;
      _activeCampaigns = activeCampaigns;
      _activeCampaignDivisions = activeCampaignDivisions;
      _selectedCampaignId = selectedCampaignId;
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
            Text(t.campaigns.select.hint, style: theme.textTheme.bodySmall),
            SizedBox(height: 16),
            _loading
                ? Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _activeCampaigns
                            .map(
                              (c) => Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
                                ),
                                child: RadioListTile<String>(
                                  value: c.id,
                                  groupValue: _selectedCampaignId,
                                  onChanged: (value) => setState(() {
                                    _selectedCampaignId = value!;
                                  }),
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
                                  visualDensity: VisualDensity(
                                    vertical: VisualDensity.minimumDensity,
                                    horizontal: VisualDensity.minimumDensity,
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _closeAndSave() {
    var appSettings = GetIt.I<AppSettings>();
    appSettings.campaign.activeCampaign.recentSelectedCampaignId = _selectedCampaignId;
    Navigator.of(context).pop();
  }
}
