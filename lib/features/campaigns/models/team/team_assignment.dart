import 'package:turf/turf.dart';

class AssignedElement {
  final String id;
  final TeamAssignmentStatus status;
  final String name;
  final TeamAssignmentType type;
  final AssignedElementType elementType;
  final DateTime assignmentDate;
  final String assignee;
  final GeometryObject coords;

  AssignedElement({
    required this.id,
    required this.status,
    required this.name,
    required this.type,
    required this.elementType,
    required this.assignmentDate,
    required this.assignee,
    required this.coords,
  });
}

enum AssignedElementType { route, area }

enum TeamAssignmentStatus { closed, open }

enum TeamAssignmentType { door, flyer, poster }
