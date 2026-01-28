import 'package:flutter/material.dart' hide Route;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
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
  bool _loading = false;
  bool _showClosedElements = false;
  List<AssignedElement> _assignedElements = <AssignedElement>[];

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

    setState(() {
      _loading = false;
      _assignedElements = [
        ...assignedElements.routes.map((r) => r.asAssignedElement()),
        ...assignedElements.areas.map((a) => a.asAssignedElement()),
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
            ..._getAssignedElementRows(assignedElementDisplayList),
          ],
        ),
      ),
    );
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
      child: GestureDetector(
        onTap: () => _switchToMap(assignedElement),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: SvgPicture.asset(_getAssetLocationByAssignmentType(assignedElement.type)),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignedElement.name, style: theme.textTheme.titleMedium),

                Text(
                  _getAssignmentInfoText(assignedElement),
                  style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (assignedElement.status == TeamAssignmentStatus.closed) {
      item = Stack(
        children: [
          item,
          Positioned.fill(child: Container(color: ThemeColors.disabledShadow.withAlpha(170))),
        ],
      );
    }
    return item;
  }

  String _getAssetLocationByAssignmentType(TeamAssignmentType type) {
    switch (type) {
      case TeamAssignmentType.door:
        return 'assets/symbols/doors/door.svg';
      case TeamAssignmentType.flyer:
        return 'assets/symbols/flyer/flyer.svg';
      case TeamAssignmentType.poster:
        return 'assets/symbols/posters/poster.svg';
    }
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
}
