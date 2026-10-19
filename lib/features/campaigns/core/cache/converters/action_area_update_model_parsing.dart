part of '../converters.dart';

extension ActionAreaUpdateModelParsing on ActionAreaStatusUpdateModel {
  ActionAreaDetailModel toVirtualActionAreaDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(status: status, isVirtual: true);
    return newActionAreaDetail;
  }
}

extension ActionAreaAssignmentUpdateModelParsing on ActionAreaAssignmentUpdateModel {
  ActionAreaDetailModel toVirtualActionAreaDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(team: Wrapped.value(team), isVirtual: true);
    return newActionAreaDetail;
  }
}
