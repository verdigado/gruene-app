part of '../converters.dart';

extension ActionAreaUpdateModelParsing on ActionAreaUpdateModel {
  ActionAreaDetailModel transformToVirtualActionAreaDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(status: status, isVirtual: true);
    return newActionAreaDetail;
  }
}
