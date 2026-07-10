part of '../converters.dart';

extension TeamRouteParsing on Route {
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
  TeamAssignmentStatus asTeamAsssignmentStatus() {
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
