part of '../converters.dart';

extension ActionAreaAssignmentUpdateModelMapping on ActionAreaAssignmentUpdateModel {
  ActionAreaDetailModel toVirtualActionAreaDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(team: Wrapped.value(team), isVirtual: true);
    return newActionAreaDetail;
  }
}
