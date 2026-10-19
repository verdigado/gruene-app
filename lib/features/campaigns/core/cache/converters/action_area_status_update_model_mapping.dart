part of '../converters.dart';

extension ActionAreaStatusUpdateModelMapping on ActionAreaStatusUpdateModel {
  ActionAreaDetailModel toVirtualActionAreaDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(status: status, isVirtual: true);
    return newActionAreaDetail;
  }
}
