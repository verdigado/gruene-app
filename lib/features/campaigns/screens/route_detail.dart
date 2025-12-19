import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/services/gruene_api_user_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/models/route/route_detail_model.dart';
import 'package:gruene_app/features/campaigns/screens/teams/select_team_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/close_edit_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';
import 'package:turf/helpers.dart';
import 'package:turf/turf.dart' as turf;

class RouteDetail extends StatefulWidget {
  const RouteDetail({super.key, required this.routeDetail, required this.mapController});

  final RouteDetailModel routeDetail;
  final MapController mapController;

  @override
  State<RouteDetail> createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {
  final _campaignActionCache = GetIt.I<CampaignActionCache>();
  late RouteDetailModel _currentRouteDetail;
  bool _loading = true;
  late UserRbacStructure _currentUserInfo;
  late Division? _currentUserKV;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<RouteDetailModel> _getLatestRouteDetail() async {
    var poiId = widget.routeDetail.id;
    var action = await _campaignActionCache.getLatest(PoiCacheType.route, poiId);
    if (action == null) return widget.routeDetail;
    switch (action.actionType) {
      case CampaignActionType.editRouteAssignment:
        return action.getAsRouteAssignmentUpdate().transformToVirtualRouteDetailModel();
      case CampaignActionType.editRoute:
        return action.getAsRouteUpdate().transformToVirtualRouteDetailModel();
      case CampaignActionType.unknown:
      case CampaignActionType.addPoster:
      case CampaignActionType.editPoster:
      case CampaignActionType.deletePoster:
      case CampaignActionType.addDoor:
      case CampaignActionType.editDoor:
      case CampaignActionType.deleteDoor:
      case CampaignActionType.addFlyer:
      case CampaignActionType.editFlyer:
      case CampaignActionType.deleteFlyer:
      case CampaignActionType.editActionArea:
      case CampaignActionType.editActionAreaAssignment:
      case null:
        throw UnimplementedError();
    }
  }

  void _loadData() async {
    setState(() => _loading = true);

    var routeDetail = await _getLatestRouteDetail();
    var userInfo = await GetIt.I<GrueneApiUserService>().getOwnRbac();
    var profileService = GetIt.I<GrueneApiProfileService>();
    var currentUserKV = (await profileService.getSelf()).getOwnKV();

    setState(() {
      _loading = false;
      _currentRouteDetail = routeDetail;
      _currentUserInfo = userInfo;
      _currentUserKV = currentUserKV;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 6),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    var theme = Theme.of(context);
    var formatter = NumberFormat.decimalPatternDigits(locale: t.$meta.locale.languageCode, decimalDigits: 0);
    onClose() => Navigator.maybePop(context);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .30),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
            child: CloseEditWidget(onClose: () => onClose()),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27, vertical: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _currentRouteDetail.name ?? '-',
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
                        '${t.campaigns.route.routeType_label}: ${_currentRouteDetail.type.getAsLabel()}',
                        style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.route.length_label}: ${formatter.format(turf.length(turf.Feature<turf.LineString>(geometry: _currentRouteDetail.lineString.asTurfLine()), Unit.meters))} m',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.general.createdAt}1: ${_currentRouteDetail.createdAt}',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
            ),
            child: Row(
              children: [
                SizedBox(width: 6),
                Icon(Icons.group_outlined, size: 30),
                SizedBox(width: 35),
                Expanded(
                  child: GestureDetector(
                    onTap: () => (_currentUserInfo.isCampaignManager() && _currentUserKV != null)
                        ? _selectTeam(_currentRouteDetail)
                        : null,
                    child: Text(
                      _currentRouteDetail.team?.name ?? t.campaigns.route.quick_action_assign_team,
                      style: theme.textTheme.bodyLarge,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Switch(
                  value: _currentRouteDetail.status == TeamRouteStatus.closed,
                  onChanged: (bool state) => _changeRouteStatus(_currentRouteDetail, state),
                ),
                SizedBox(width: 12),
                Text(t.campaigns.route.quick_action_status, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeRouteStatus(RouteDetailModel route, bool state) async {
    var newStatus = state ? TeamRouteStatus.closed : TeamRouteStatus.open;
    var routeUpdate = route.asRouteUpdate().copyWith(status: newStatus);

    var feature = await _campaignActionCache.updatePoi(PoiCacheType.route, routeUpdate);
    widget.mapController.setLayerSourceWithFeatureList(CampaignConstants.routesSourceName, [feature]);
    setState(() {
      _currentRouteDetail = routeUpdate.transformToVirtualRouteDetailModel();
    });
  }

  Future<void> _selectTeam(RouteDetailModel route) async {
    if (_currentUserKV == null) return;
    var teamsService = GetIt.I<GrueneApiTeamsService>();

    var userTeams = await teamsService.findTeams(_currentUserKV!.divisionKey);
    if (!mounted) return;
    var selectedTeam = await showModalBottomSheet<FindTeamsItem>(
      context: context,
      builder: (context) => SelectTeamWidget(teams: userTeams),
    );

    if (selectedTeam != null) {
      var routeAssignmentUpdate = route.asRouteAssignmentUpdate().copyWith(team: selectedTeam.asRouteTeam());
      var feature = await _campaignActionCache.updatePoi(PoiCacheType.route, routeAssignmentUpdate);
      widget.mapController.setLayerSourceWithFeatureList(CampaignConstants.routesSourceName, [feature]);
      setState(() {
        _currentRouteDetail = routeAssignmentUpdate.transformToVirtualRouteDetailModel();
      });
    }
  }
}
