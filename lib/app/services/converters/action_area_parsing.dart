part of '../converters.dart';

extension ActionAreaParsing on Area {
  ActionAreaDetailModel asActionAreaDetail() {
    return ActionAreaDetailModel(
      id: id,
      type: type,
      comment: comment,
      name: name,
      status: status,
      polygon: polygon,
      createdAt: createdAt.getAsLocalDateString(),
      team: team,
    );
  }
}

extension ActionAreaListParsing on List<Area> {
  List<turf.Feature<turf.Polygon>> transformToFeatureList() {
    return map((p) => p.asActionAreaDetail().transformToFeatureItem()).toList();
  }
}

extension AreaAssignmentParsing on AreaAssignment {
  AssignedElement asAssignedElement() {
    return AssignedElement(
      status: status.asTeamAsssignmentStatus(),
      name: name ?? '',
      type: type.asTeamAssignmentType(),
      elementType: AssignedElementType.area,
      assignmentDate: assignedAt ?? DateTime.now(),
      assignee: assigningUser,
      coords: polygon.asTurfPolygon(),
    );
  }
}

extension on AreaAssignmentStatus {
  TeamAssignmentStatus asTeamAsssignmentStatus() {
    switch (this) {
      case AreaAssignmentStatus.open:
        return TeamAssignmentStatus.open;
      case AreaAssignmentStatus.closed:
        return TeamAssignmentStatus.closed;

      case AreaAssignmentStatus.assigned:
      case AreaAssignmentStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}

extension on AreaAssignmentType {
  TeamAssignmentType asTeamAssignmentType() {
    switch (this) {
      case AreaAssignmentType.flyerSpot:
        return TeamAssignmentType.flyer;
      case AreaAssignmentType.poster:
        return TeamAssignmentType.poster;
      case AreaAssignmentType.house:
        return TeamAssignmentType.door;

      case AreaAssignmentType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
