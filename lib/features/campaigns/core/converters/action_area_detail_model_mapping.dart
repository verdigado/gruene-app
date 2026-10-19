part of '../converters.dart';

extension ActionAreaDetailModelMapping on ActionAreaDetailModel {
  ActionAreaStatusUpdateModel toActionAreaStatusUpdate() {
    return ActionAreaStatusUpdateModel(id: id, status: status, actionAreaDetail: this);
  }

  ActionAreaAssignmentUpdateModel toActionAreaAssignmentUpdate() {
    return ActionAreaAssignmentUpdateModel(id: id, team: team, actionAreaDetail: this);
  }
}
