part of '../converters.dart';

extension ActionAreaUpdateModelParsing on ActionAreaUpdateModel {
  ActionAreaDetailModel transformToActionAreaDetailModel() {
    var newFlyerDetail = actionAreaDetail.copyWith(status: status, isCached: true);
    return newFlyerDetail;
  }
}
