part of '../converters.dart';

extension AreaMapping on Area {
  ActionAreaDetailModel toActionAreaDetail() {
    return ActionAreaDetailModel(
      id: id,
      type: type,
      comment: comment,
      name: name,
      status: status,
      polygon: polygon,
      visualIdentifierId: visualIdentifierId,
      createdAt: createdAt.toLocalDateString(),
      team: team,
    );
  }
}

extension AreaAssignmentMapping on AreaAssignment {
  AssignedElement toAssignedElement() {
    return AssignedElement(
      id: id,
      status: status.toTeamAssignmentStatus(),
      name: name ?? '',
      type: type.toTeamAssignmentType(),
      elementType: AssignedElementType.area,
      assignmentDate: assignedAt ?? DateTime.now(),
      assignee: assigningUser,
      coords: polygon.toTurfPolygon(),
      campaignId: campaignId,
    );
  }
}

extension on AreaStatus {
  TeamAssignmentStatus toTeamAssignmentStatus() {
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
  TeamAssignmentType toTeamAssignmentType() {
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
