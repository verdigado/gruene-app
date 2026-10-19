part of '../converters.dart';

extension RouteMapping on Route {
  RouteDetailModel toRouteDetail() {
    return RouteDetailModel(
      id: id,
      type: type,
      name: name,
      description: description,
      status: status,
      lineString: lineString,
      createdAt: createdAt.toLocalDateString(),
      team: team,
      visualIdentifierId: visualIdentifierId,
    );
  }
}

extension RouteAssignmentMapping on RouteAssignment {
  AssignedElement toAssignedElement() {
    return AssignedElement(
      id: id,
      status: status.toTeamAssignmentStatus(),
      name: name ?? '',
      type: type.toTeamAssignmentType(),
      elementType: AssignedElementType.route,
      assignmentDate: assignedAt ?? DateTime.now(),
      assignee: assigningUser,
      coords: lineString.toTurfLine(),
      campaignId: campaignId,
    );
  }
}

extension on RouteType {
  TeamAssignmentType toTeamAssignmentType() {
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
  TeamAssignmentStatus toTeamAssignmentStatus() {
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
