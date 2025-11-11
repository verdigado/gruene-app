part of '../converters.dart';

extension FlyerCreateModelParsing on FlyerCreateModel {
  FlyerDetailModel transformToFlyerDetailModel(String temporaryId) {
    return FlyerDetailModel(
      id: temporaryId,
      address: address,
      flyerCount: flyerCount,
      location: location,
      createdAt: '${DateTime.now().getAsLocalDateTimeString()}*', // should mark this as preliminary
      isCached: true,
    );
  }

  PoiDetailModel transformToVirtualMarkerItem(int temporaryId) {
    return PoiDetailModel.virtual(id: temporaryId, status: PoiServiceType.flyer.name, location: location);
  }
}
