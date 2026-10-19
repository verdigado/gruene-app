part of '../converters.dart';

extension FlyerCreateModelMapping on FlyerCreateModel {
  FlyerDetailModel toFlyerDetailModel(String temporaryId) {
    return FlyerDetailModel(
      id: temporaryId,
      address: address,
      flyerCount: flyerCount,
      location: location,
      createdAt: '${DateTime.now().toLocalDateTimeString()}*', // should mark this as preliminary
      isCached: true,
    );
  }

  PoiDetailModel toVirtualPoiDetailModel(int temporaryId) {
    return PoiDetailModel.virtual(id: temporaryId, status: PoiServiceType.flyer.name, location: location);
  }
}
