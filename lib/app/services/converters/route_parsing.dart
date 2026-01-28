part of '../converters.dart';

extension TeamRouteParsing on Route {
  RouteDetailModel asRouteDetail() {
    return RouteDetailModel(
      id: id,
      type: type,
      name: name,
      status: status,
      lineString: lineString,
      createdAt: createdAt.getAsLocalDateString(),
      team: team,
    );
  }
}

extension RouteListParsing on List<Route> {
  List<turf.Feature<turf.LineString>> transformToFeatureList() {
    return map((p) => p.asRouteDetail().transformToFeatureItem()).toList();
  }
}

extension RouteAssignmentParsing on RouteAssignment {
  AssignedElement asAssignedElement() {
    return AssignedElement(
      id: id,
      status: status.asTeamAsssignmentStatus(),
      name: name ?? '',
      type: type.asTeamAssignmentType(),
      elementType: AssignedElementType.route,
      assignmentDate: assignedAt ?? DateTime.now(),
      assignee: assigningUser,
      coords: lineString.asTurfLine(),
    );
  }
}

extension on RouteAssignmentType {
  TeamAssignmentType asTeamAssignmentType() {
    switch (this) {
      case RouteAssignmentType.flyerSpot:
        return TeamAssignmentType.flyer;
      case RouteAssignmentType.poster:
        return TeamAssignmentType.poster;
      case RouteAssignmentType.house:
        return TeamAssignmentType.door;

      case RouteAssignmentType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}

extension on RouteAssignmentStatus {
  TeamAssignmentStatus asTeamAsssignmentStatus() {
    switch (this) {
      case RouteAssignmentStatus.open:
        return TeamAssignmentStatus.open;
      case RouteAssignmentStatus.closed:
        return TeamAssignmentStatus.closed;

      case RouteAssignmentStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
