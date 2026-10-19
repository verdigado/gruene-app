part of '../converters.dart';

extension AreaMapping on Area {
  ActionAreaDetailModel asActionAreaDetail() {
    return ActionAreaDetailModel(
      id: id,
      type: type,
      comment: comment,
      name: name,
      status: status,
      polygon: polygon,
      visualIdentifierId: visualIdentifierId,
      createdAt: createdAt.getAsLocalDateString(),
      team: team,
    );
  }
}

extension AreaAssignmentMapping on AreaAssignment {
  AssignedElement asAssignedElement() {
    return AssignedElement(
      id: id,
      status: status.asTeamAssignmentStatus(),
      name: name ?? '',
      type: type.asTeamAssignmentType(),
      elementType: AssignedElementType.area,
      assignmentDate: assignedAt ?? DateTime.now(),
      assignee: assigningUser,
      coords: polygon.asTurfPolygon(),
      campaignId: campaignId,
    );
  }
}

extension on AreaStatus {
  TeamAssignmentStatus asTeamAssignmentStatus() {
    switch (this) {
      case AreaStatus.open:
        return TeamAssignmentStatus.open;
      case AreaStatus.closed:
        return TeamAssignmentStatus.closed;

      case AreaStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}

extension on AreaType {
  TeamAssignmentType asTeamAssignmentType() {
    switch (this) {
      case AreaType.flyerSpot:
        return TeamAssignmentType.flyer;
      case AreaType.poster:
        return TeamAssignmentType.poster;
      case AreaType.house:
        return TeamAssignmentType.door;

      case AreaType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
