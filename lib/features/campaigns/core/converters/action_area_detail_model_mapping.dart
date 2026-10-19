part of '../converters.dart';

extension ActionAreaDetailModelMapping on ActionAreaDetailModel {
  ActionAreaStatusUpdateModel asActionAreaUpdate() {
    return ActionAreaStatusUpdateModel(id: id, status: status, actionAreaDetail: this);
  }

  ActionAreaAssignmentUpdateModel asActionAreaAssignmentUpdate() {
    return ActionAreaAssignmentUpdateModel(id: id, team: team, actionAreaDetail: this);
  }
}
