part of '../converters.dart';

extension FlyerUpdateModelParsing on FlyerUpdateModel {
  FlyerDetailModel transformToFlyerDetailModel() {
    var newFlyerDetail = oldFlyerDetail.copyWith(
      address: address,
      flyerCount: flyerCount,
      isCached: true,
    );
    return newFlyerDetail;
  }

  MarkerItemModel transformToVirtualMarkerItem() {
    return MarkerItemModel.virtual(
      id: int.parse(id),
      status: PoiServiceType.flyer.name,
      location: location,
    );
  }
}
