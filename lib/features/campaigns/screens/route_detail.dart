import 'package:flutter/material.dart' hide Route;
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/models/route/route_detail_model.dart';
import 'package:gruene_app/features/campaigns/widgets/close_edit_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class RouteDetail extends StatefulWidget {
  const RouteDetail({super.key, required this.routeDetail});

  final RouteDetailModel routeDetail;

  @override
  State<RouteDetail> createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {
  final _campaignActionCache = GetIt.I<CampaignActionCache>();

  @override
  void initState() {
    super.initState();
  }

  Future<RouteStatus> _getLatestStatus() async {
    var poiId = widget.routeDetail.id;

    return await _campaignActionCache.isCached(poiId)
        ? (await _campaignActionCache.getPoiAsRouteDetail(poiId)).status
        : widget.routeDetail.status;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
                        '${t.campaigns.route.label} #${widget.routeDetail.id}',
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
                        '${t.campaigns.route.routeType_label}: ${widget.routeDetail.type.getAsLabel()}',
                        style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.route.createdAt}: ${widget.routeDetail.createdAt}',
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
                var currentState = snapshot.hasData ? snapshot.data : RouteStatus.open;
                var currentOnChanged = snapshot.hasData
                    ? (bool state) => _changeRouteStatus(widget.routeDetail, state)
                    : null;
                var content = Row(
                  children: [
                    Switch(value: currentState == RouteStatus.closed, onChanged: currentOnChanged),
                    SizedBox(width: 12),
                    Text(t.campaigns.route.quick_action_label, style: theme.textTheme.bodyLarge),
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

  Future<void> _changeRouteStatus(RouteDetailModel route, bool state) async {
    var newStatus = state ? RouteStatus.closed : RouteStatus.open;
    var routeUpdate = route.asRouteUpdate().copyWith(status: newStatus);

    await _campaignActionCache.updatePoi(PoiCacheType.route, routeUpdate);
    setState(() {});
  }
}
