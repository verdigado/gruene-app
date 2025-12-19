import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
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

    // await Future.delayed(Duration(seconds: 1));

    // TODO #736 remove mock data when getOwnTeam and getAssignedData is working
    await Future<void>.delayed(Duration(milliseconds: 250));
    // var teamsService = GetIt.I<GrueneApiTeamsService>();
    // var team = await teamsService.getAssignedElements(widget.currentTeam.id);
    var assignedElements = [
      AssignedElement(
        name: 'Haustür-Route 8838',
        type: TeamAssignmentType.door,
        status: TeamAssignmentStatus.open,
        elementType: ElementType.route,
        coords: turf.LineString(coordinates: [turf.Position(0, 0), turf.Position(1, 1)]),
        assignmentDate: DateTime(2025, 9, 12),
        assignee: 'Renate S.',
      ),
      AssignedElement(
        name: 'von Kotti bis U-Schönlein',
        type: TeamAssignmentType.poster,
        status: TeamAssignmentStatus.open,
        elementType: ElementType.route,
        coords: turf.LineString(coordinates: [turf.Position(10, 10), turf.Position(11, 11)]),
        assignmentDate: DateTime(2025, 9, 11),
        assignee: 'Paul W.',
      ),
      AssignedElement(
        name: 'Plakat-Route 11223',
        type: TeamAssignmentType.poster,
        status: TeamAssignmentStatus.open,
        elementType: ElementType.route,
        coords: turf.LineString(coordinates: [turf.Position(20, 20), turf.Position(21, 21)]),
        assignmentDate: DateTime(2025, 9, 10),
        assignee: 'Renate S.',
      ),
      AssignedElement(
        name: 'U Warschauer flyern',
        type: TeamAssignmentType.flyer,
        status: TeamAssignmentStatus.open,
        elementType: ElementType.area,
        coords: turf.Polygon(
          coordinates: [
            [turf.Position(0, 0), turf.Position(0, 1), turf.Position(1, 1), turf.Position(1, 0), turf.Position(0, 0)],
          ],
        ),
        assignmentDate: DateTime(2025, 9, 9),
        assignee: 'Anne M.',
      ),
      AssignedElement(
        name: 'V Klimtstraße',
        type: TeamAssignmentType.flyer,
        status: TeamAssignmentStatus.closed,
        elementType: ElementType.area,
        coords: turf.Polygon(
          coordinates: [
            [
              turf.Position(10, 10),
              turf.Position(10, 11),
              turf.Position(11, 11),
              turf.Position(11, 10),
              turf.Position(10, 10),
            ],
          ],
        ),
        assignmentDate: DateTime(2024, 8, 15),
        assignee: 'Max K.',
        closedDate: DateTime(2025, 1, 20),
      ),
      AssignedElement(
        name: 'Schönbrunner Strasse',
        type: TeamAssignmentType.flyer,
        status: TeamAssignmentStatus.closed,
        elementType: ElementType.area,
        coords: turf.Polygon(
          coordinates: [
            [
              turf.Position(20, 20),
              turf.Position(20, 21),
              turf.Position(21, 21),
              turf.Position(21, 20),
              turf.Position(20, 20),
            ],
          ],
        ),
        assignmentDate: DateTime(2023, 3, 20),
        assignee: 'Lisa T.',
        closedDate: DateTime(2025, 1, 10),
      ),
      AssignedElement(
        name: 'Neuwaldegger Platz',
        type: TeamAssignmentType.flyer,
        status: TeamAssignmentStatus.closed,
        elementType: ElementType.area,
        coords: turf.Polygon(
          coordinates: [
            [
              turf.Position(30, 30),
              turf.Position(30, 31),
              turf.Position(31, 31),
              turf.Position(31, 30),
              turf.Position(30, 30),
            ],
          ],
        ),
        assignmentDate: DateTime(2026, 6, 5),
        assignee: 'John D.',
        closedDate: DateTime(2025, 1, 1),
      ),
    ];
    assignedElements.shuffle();

    setState(() {
      _loading = false;
      _assignedElements = assignedElements;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(padding: EdgeInsets.fromLTRB(24, 24, 24, 6), child: CircularProgressIndicator());
    }
    if (_assignedElements.isEmpty) return SizedBox.shrink();

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
                  t.campaigns.team.team_assigned_elements(
                    count: _assignedElements.where((el) => el.status == TeamAssignmentStatus.open).length,
                  ),
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
            ..._getAssignedElementRows(),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _getAssignedElementRows() {
    var elementsForDisplay = !_showClosedElements
        ? _assignedElements.where((el) => el.status == TeamAssignmentStatus.open)
        : _assignedElements;

    var elementsForDisplayList = elementsForDisplay.toList();
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
    if (assignedElement.elementType == ElementType.area) {
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
    return a.status == TeamAssignmentStatus.open
        ? a.assignmentDate.compareTo(b.assignmentDate) * -1
        : a.closedDate!.compareTo(b.closedDate!) * -1;
  }
}

class AssignedElement {
  final TeamAssignmentStatus status;
  final String name;
  final TeamAssignmentType type;
  final ElementType elementType;
  final turf.GeometryObject coords;
  final DateTime assignmentDate;
  final String assignee;
  final DateTime? closedDate;

  AssignedElement({
    required this.status,
    required this.name,
    required this.type,
    required this.elementType,
    required this.coords,
    required this.assignmentDate,
    required this.assignee,
    this.closedDate,
  });
}

enum ElementType { route, area }

enum TeamAssignmentStatus { closed, open }

enum TeamAssignmentType { door, flyer, poster }
