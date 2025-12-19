part of '../converters.dart';

extension ActionAreaUpdateModelParsing on ActionAreaUpdateModel {
  ActionAreaDetailModel transformToVirtualActionAreaDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(status: status, isVirtual: true);
    return newActionAreaDetail;
  }
}

extension ActionAreaAssignmentUpdateModelParsing on ActionAreaAssignmentUpdateModel {
  ActionAreaDetailModel transformToVirtualActionAreaDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(team: team, isVirtual: true);
    return newActionAreaDetail;
  }
}
