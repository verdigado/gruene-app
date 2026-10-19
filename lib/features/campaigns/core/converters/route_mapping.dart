part of '../converters.dart';

extension RouteMapping on Route {
  RouteDetailModel asRouteDetail() {
    return RouteDetailModel(
      id: id,
      type: type,
      name: name,
      description: description,
      status: status,
      lineString: lineString,
      createdAt: createdAt.getAsLocalDateString(),
      team: team,
      visualIdentifierId: visualIdentifierId,
    );
  }
}

extension RouteAssignmentMapping on RouteAssignment {
  AssignedElement asAssignedElement() {
    return AssignedElement(
      id: id,
      status: status.asTeamAssignmentStatus(),
      name: name ?? '',
      type: type.asTeamAssignmentType(),
      elementType: AssignedElementType.route,
      assignmentDate: assignedAt ?? DateTime.now(),
      assignee: assigningUser,
      coords: lineString.asTurfLine(),
      campaignId: campaignId,
    );
  }
}

extension on RouteType {
  TeamAssignmentType asTeamAssignmentType() {
    switch (this) {
      case RouteType.flyerSpot:
        return TeamAssignmentType.flyer;
      case RouteType.poster:
        return TeamAssignmentType.poster;
      case RouteType.house:
        return TeamAssignmentType.door;

      case RouteType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}

extension on RouteStatus {
  TeamAssignmentStatus asTeamAssignmentStatus() {
    switch (this) {
      case RouteStatus.open:
        return TeamAssignmentStatus.open;
      case RouteStatus.closed:
        return TeamAssignmentStatus.closed;

      case RouteStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
