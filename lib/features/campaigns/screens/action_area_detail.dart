import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/services/gruene_api_user_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/models/action_area/action_area_detail_model.dart';
import 'package:gruene_app/features/campaigns/screens/teams/select_team_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/close_edit_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';
import 'package:turf/turf.dart' as turf;

class ActionAreaDetail extends StatefulWidget {
  const ActionAreaDetail({super.key, required this.actionAreaDetail, required this.mapController});

  final ActionAreaDetailModel actionAreaDetail;
  final MapController mapController;

  @override
  State<ActionAreaDetail> createState() => _ActionAreaDetailState();
}

class _ActionAreaDetailState extends State<ActionAreaDetail> {
  final _campaignActionCache = GetIt.I<CampaignActionCache>();
  late ActionAreaDetailModel _currentActionAreaDetail;
  late UserRbacStructure _currentUserInfo;
  late Division? _currentUserKV;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    var userService = GetIt.I<GrueneApiUserService>();
    var profileService = GetIt.I<GrueneApiProfileService>();

    final (userInfo, currentUser) = await (userService.getOwnRbac(), profileService.getSelf()).wait;

    setState(() {
      _loading = false;
      _currentActionAreaDetail = widget.actionAreaDetail;
      _currentUserInfo = userInfo;
      _currentUserKV = currentUser.getOwnKV();
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
    var formatter = NumberFormat.decimalPattern(t.$meta.locale.languageCode);
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
          ((!_currentUserInfo.isCampaignManager() || _currentUserKV == null) && _currentActionAreaDetail.team == null)
              ? SizedBox.shrink()
              : _getAssignmentWidget(theme),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Switch(
                  value: _currentActionAreaDetail.status == AreaStatus.closed,
                  onChanged: (bool state) => _changeActionAreaStatus(_currentActionAreaDetail, state),
                ),
                SizedBox(width: 12),
                Text(t.campaigns.action_area.quick_action_status, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAssignmentWidget(ThemeData theme) {
    var widget = Container(
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
                  ? _selectTeam(_currentActionAreaDetail)
                  : null,
              child: Text(
                _currentActionAreaDetail.team?.name ?? t.campaigns.route.quick_action_assign_team,
                style: theme.textTheme.bodyLarge,
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );

    return _currentActionAreaDetail.status == AreaStatus.closed ? widget.disable() : widget;
  }

  Future<void> _changeActionAreaStatus(ActionAreaDetailModel actionArea, bool state) async {
    var newStatus = state ? AreaStatus.closed : AreaStatus.open;
    var actionAreaUpdate = actionArea.asActionAreaUpdate().copyWith(status: newStatus);

    var feature = await _campaignActionCache.updatePoi(PoiCacheType.actionArea, actionAreaUpdate);
    await widget.mapController.setLayerSourceWithFeatureList(CampaignConstants.actionAreaSourceName, [feature]);
    setState(() {
      _currentActionAreaDetail = actionAreaUpdate.transformToVirtualActionAreaDetailModel();
    });
  }

  Future<void> _selectTeam(ActionAreaDetailModel actionArea) async {
    if (_currentUserKV == null) return;
    var teamsService = GetIt.I<GrueneApiTeamsService>();

    var userTeams = await teamsService.findTeams(_currentUserKV!.divisionKey);
    if (!mounted) return;
    var selectedTeam = await showModalBottomSheet<FindTeamsItem>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SelectTeamWidget(teams: userTeams, routeOrArea: TeamAssignmentType.area),
    );

    if (selectedTeam != null) {
      var actionAreaAssignmentUpdate = actionArea.asActionAreaAssignmentUpdate().copyWith(
        team: selectedTeam.asRouteTeam(),
      );
      var feature = await _campaignActionCache.updatePoi(PoiCacheType.actionArea, actionAreaAssignmentUpdate);
      await widget.mapController.setLayerSourceWithFeatureList(CampaignConstants.actionAreaSourceName, [feature]);
      setState(() {
        _currentActionAreaDetail = actionAreaAssignmentUpdate.transformToVirtualActionAreaDetailModel();
      });
    }
  }
}
