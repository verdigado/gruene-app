part of '../converters.dart';

extension ActionAreaUpdateModelParsing on ActionAreaUpdateModel {
  // ActionAreaDetailModel transformToActionAreaDetailModel() {
  //   var newFlyerDetail = actionAreaDetail.copyWith(status: status, isVirtual: true);
  //   return newFlyerDetail;
  // }
  ActionAreaDetailModel transformToVirtualRouteDetailModel() {
    var newActionAreaDetail = actionAreaDetail.copyWith(status: status, isVirtual: true);
    return newActionAreaDetail;
  }
}
