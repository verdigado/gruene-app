import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/models/action_area/action_area_detail_model.dart';
import 'package:gruene_app/features/campaigns/widgets/close_edit_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';
import 'package:turf/turf.dart' as turf;

class ActionAreaDetail extends StatefulWidget {
  const ActionAreaDetail({super.key, required this.actionAreaDetail});

  final ActionAreaDetailModel actionAreaDetail;

  @override
  State<ActionAreaDetail> createState() => _ActionAreaDetailState();
}

class _ActionAreaDetailState extends State<ActionAreaDetail> {
  final _campaignActionCache = GetIt.I<CampaignActionCache>();

  @override
  void initState() {
    super.initState();
  }

  Future<AreaStatus> _getLatestStatus() async {
    var poiId = widget.actionAreaDetail.id;

    return await _campaignActionCache.isCached(poiId, PoiCacheType.actionArea)
        ? (await _campaignActionCache.getPoiAsActionAreaDetail(poiId)).status
        : widget.actionAreaDetail.status;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var formatter = NumberFormat.decimalPattern(t.$meta.locale.languageCode);
    onClose() => Navigator.maybePop(context);

    return SizedBox(
      height: 158,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
            child: CloseEditWidget(onClose: () => onClose()),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.actionAreaDetail.name ?? '-',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: ThemeColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.action_area.area_label}: ${formatter.format(turf.area(widget.actionAreaDetail.polygon.asTurfPolygon())! / 1000 / 1000)} km²',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.general.createdAt}: ${widget.actionAreaDetail.createdAt}',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: ThemeColors.grey100),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder(
              future: _getLatestStatus(),
              builder: (context, snapshot) {
                var currentState = snapshot.hasData ? snapshot.data : AreaStatus.open;
                var currentOnChanged = snapshot.hasData
                    ? (bool state) => _changeActionAreaStatus(widget.actionAreaDetail, state)
                    : null;
                var content = Row(
                  children: [
                    Switch(value: currentState == AreaStatus.closed, onChanged: currentOnChanged),
                    SizedBox(width: 12),
                    Text(t.campaigns.action_area.quick_action_label, style: theme.textTheme.bodyLarge),
                  ],
                );
                if (snapshot.hasData) {
                  return content;
                } else {
                  return Stack(
                    children: [
                      content,
                      Positioned.fill(child: Container(color: ThemeColors.grey100.withAlpha(100))),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeActionAreaStatus(ActionAreaDetailModel actionArea, bool state) async {
    var newStatus = state ? AreaStatus.closed : AreaStatus.open;
    var actionAreaUpdate = actionArea.asActionAreaUpdate().copyWith(status: newStatus);

    await _campaignActionCache.updatePoi(PoiCacheType.actionArea, actionAreaUpdate);
    setState(() {});
  }
}
