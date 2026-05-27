import 'package:flutter/material.dart' hide Route;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/utils/globals.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/campaigns/controllers/map_screen_controller.dart';
import 'package:gruene_app/features/campaigns/models/team/team_assignment.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;
import 'package:intl/intl.dart';
import 'package:turf/turf.dart' as turf;

class TeamAssignedElements extends StatefulWidget {
  final Team currentTeam;

  const TeamAssignedElements({super.key, required this.currentTeam});

  @override
  State<TeamAssignedElements> createState() => _TeamAssignedElementsState();
}

class _TeamAssignedElementsState extends State<TeamAssignedElements> {
  bool _loading = true;
  bool _showClosedElements = false;
  List<AssignedElement> _assignedElements = <AssignedElement>[];
  List<Campaign> _activeCampaigns = <Campaign>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    var teamsService = GetIt.I<GrueneApiTeamsService>();
    var assignedElements = await teamsService.getTeamAssignments(teamId: widget.currentTeam.id);

    var campaignIds = assignedElements.routes.map((r) => r.campaignId).toList();
    campaignIds.addAll(assignedElements.areas.map((a) => a.campaignId));
    campaignIds = campaignIds.groupBy((c) => c).keys.toList();

    var campaignService = GetIt.I<GrueneApiCampaignService>();
    var activeCampaigns = (await campaignService.findCampaigns()).activeCampaigns();

    setState(() {
      _loading = false;
      _activeCampaigns = activeCampaigns;
      _assignedElements = [
        ...assignedElements.routes
            .where((r) => activeCampaigns.any((c) => c.id == r.campaignId))
            .map((r) => r.asAssignedElement()),
        ...assignedElements.areas
            .where((a) => activeCampaigns.any((c) => c.id == a.campaignId))
            .map((a) => a.asAssignedElement()),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(padding: EdgeInsets.fromLTRB(24, 24, 24, 6), child: CircularProgressIndicator());
    }
    if (_assignedElements.isEmpty) return SizedBox.shrink();

    var assignedElementDisplayList =
        (!_showClosedElements
                ? _assignedElements.where((el) => el.status == TeamAssignmentStatus.open)
                : _assignedElements)
            .toList();

    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: boxShadowDecoration,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.campaigns.team.team_assigned_elements(count: assignedElementDisplayList.length),
                  style: theme.textTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _showClosedElements = !_showClosedElements;
                  }),
                  child: Text(
                    _showClosedElements
                        ? t.campaigns.team.team_assigned_elements_hide_closed
                        : t.campaigns.team.team_assigned_elements_show_closed,
                    style: theme.textTheme.labelMedium?.apply(
                      decoration: TextDecoration.underline,
                      color: ThemeColors.text,
                    ),
                  ),
                ),
              ],
            ),
            ..._getAssignedElementRowsByCampaign(assignedElementDisplayList),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _getAssignedElementRowsByCampaign(List<AssignedElement> assignedElementDisplayList) {
    var campaignIds = assignedElementDisplayList.map((e) => e.campaignId).groupBy(id).keys.toList();
    campaignIds.sort(sortCampaigns);
    return campaignIds.map((campaignId) {
      var campaignName = _activeCampaigns.singleWhere((c) => c.id == campaignId).name;
      return Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 12, bottom: 6),
            alignment: Alignment.centerLeft,
            child: Text(campaignName, style: Theme.of(context).textTheme.titleSmall),
          ),
          ..._getAssignedElementRows(assignedElementDisplayList.where((e) => e.campaignId == campaignId).toList()),
        ],
      );
    });
  }

  Iterable<Widget> _getAssignedElementRows(List<AssignedElement> assignedElementDisplayList) {
    var elementsForDisplayList = assignedElementDisplayList.toList();
    elementsForDisplayList.sort(compareAssignedElements);
    return elementsForDisplayList.map(_getAssignedElementRow);
  }

  Widget _getAssignedElementRow(AssignedElement assignedElement) {
    var theme = Theme.of(context);
    Widget item = Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: SvgPicture.asset(assignedElement.type.getAssetLocationByAssignmentType()),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 90),
                child: Text(assignedElement.name, style: theme.textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
              ),
              Text(
                _getAssignmentInfoText(assignedElement),
                style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled),
              ),
            ],
          ),
        ],
      ),
    );
    if (assignedElement.status == TeamAssignmentStatus.closed) {
      item = item.disable();
    }
    return InkWell(onTap: () => _switchToMap(assignedElement), child: item);
  }

  String _getAssignmentInfoText(AssignedElement assignedElement) {
    var assignmentInfo = t.campaigns.team.team_assigned_elements_assignment_info(
      date: assignedElement.assignmentDate.getAsLocalDateString(),
      assignee: assignedElement.assignee,
    );
    var formatter = NumberFormat.decimalPatternDigits(locale: t.$meta.locale.languageCode, decimalDigits: 1);
    if (assignedElement.elementType == AssignedElementType.area) {
      var areaData = turf.area(assignedElement.coords)! / 1000 / 1000;
      var areaInfo = t.campaigns.team.team_assigned_elements_area_info(area: formatter.format(areaData));
      return '$areaInfo | $assignmentInfo';
    } else {
      var routeLength = turf.length(turf.Feature(geometry: assignedElement.coords as turf.LineString));
      var routeInfo = t.campaigns.team.team_assigned_elements_route_info(distance: formatter.format(routeLength));
      return '$routeInfo | $assignmentInfo';
    }
  }

  int compareAssignedElements(AssignedElement a, AssignedElement b) {
    if (a.status != b.status) {
      return a.status == TeamAssignmentStatus.open ? -1 : 1;
    }
    return a.assignmentDate.compareTo(b.assignmentDate) * -1;
  }

  Future<void> _switchToMap(AssignedElement assignedElement) async {
    var currentSelectedCampaign = getCurrentCampaignId();
    if (currentSelectedCampaign != assignedElement.campaignId) {
      var currentCampaign = _activeCampaigns.singleWhere((c) => c.id == currentSelectedCampaign);
      var targetCampaign = _activeCampaigns.singleWhere((c) => c.id == assignedElement.campaignId);
      if (await _confirmCampaignSwitch(currentCampaign, targetCampaign)) {
        switchCampaign(targetCampaign.id);
      } else {
        return;
      }
    }
    MapScreenController mapScreenController;
    String route;
    switch (assignedElement.type) {
      case TeamAssignmentType.door:
        route = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignDoorDetail]);
        mapScreenController = GetIt.I<MapScreenController>(instanceName: PoiServiceType.door.toString());
      case TeamAssignmentType.flyer:
        route = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignFlyerDetail]);
        mapScreenController = GetIt.I<MapScreenController>(instanceName: PoiServiceType.flyer.toString());
      case TeamAssignmentType.poster:
        route = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignPosterDetail]);
        mapScreenController = GetIt.I<MapScreenController>(instanceName: PoiServiceType.poster.toString());
    }
    var localContext = context;
    if (!localContext.mounted) return;

    GoRouter.of(localContext).go(route);
    switch (assignedElement.elementType) {
      case AssignedElementType.route:
        mapScreenController.showRoute(assignedElement.id);
      case AssignedElementType.area:
        mapScreenController.showArea(assignedElement.id);
    }
  }

  Future<bool> _confirmCampaignSwitch(Campaign currentCampaign, Campaign targetCampaign) async {
    final theme = Theme.of(context);
    var dialogResult = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.campaigns.team.team_target_campaign_conflict),
          content: Text(
            t.campaigns.team.team_target_campaign_conflict_message(
              currentCampaign: currentCampaign.name,
              targetCampaign: targetCampaign.name,
            ),
            textAlign: TextAlign.left,
            style: theme.textTheme.labelLarge,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.maybePop(context, false),
              child: Text(t.common.actions.cancel, style: theme.textTheme.labelLarge?.apply(fontWeightDelta: -8)),
            ),
            TextButton(
              onPressed: () => Navigator.maybePop(context, true),
              child: Text(
                t.campaigns.team.team_target_campaign_conflict_action,
                style: theme.textTheme.labelLarge?.apply(color: theme.colorScheme.primary, fontWeightDelta: -8),
              ),
            ),
          ],
        );
      },
    );
    return dialogResult ?? false;
  }

  int sortCampaigns(String a, String b) {
    var currentSelectedCampaign = getCurrentCampaignId();
    if (a == currentSelectedCampaign) return -1;
    if (b == currentSelectedCampaign) return 1;

    var campaignA = _activeCampaigns.singleWhere((c) => c.id == a);
    var campaignB = _activeCampaigns.singleWhere((c) => c.id == b);
    return campaignA.electionDate.compareTo(campaignB.electionDate) * -1;
  }
}
