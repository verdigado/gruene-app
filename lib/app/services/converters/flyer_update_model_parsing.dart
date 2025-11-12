part of '../converters.dart';

extension FlyerUpdateModelParsing on FlyerUpdateModel {
  FlyerDetailModel transformToFlyerDetailModel() {
    var newFlyerDetail = oldFlyerDetail.copyWith(address: address, flyerCount: flyerCount, isCached: true);
    return newFlyerDetail;
  }

  PoiDetailModel transformToVirtualPoiDetailModel() {
    return PoiDetailModel.virtual(id: int.parse(id), status: PoiServiceType.flyer.name, location: location);
  }
}
