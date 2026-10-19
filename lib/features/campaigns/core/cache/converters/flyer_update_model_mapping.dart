part of '../converters.dart';

extension FlyerUpdateModelMapping on FlyerUpdateModel {
  FlyerDetailModel toFlyerDetailModel() {
    var newFlyerDetail = oldFlyerDetail.copyWith(address: address, flyerCount: flyerCount, isCached: true);
    return newFlyerDetail;
  }

  PoiDetailModel toVirtualPoiDetailModel() {
    return PoiDetailModel.virtual(id: int.parse(id), status: PoiServiceType.flyer.name, location: location);
  }
}
