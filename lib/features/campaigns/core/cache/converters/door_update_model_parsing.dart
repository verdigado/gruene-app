part of '../converters.dart';

extension DoorUpdateModelParsing on DoorUpdateModel {
  DoorDetailModel toDoorDetailModel() {
    var newDoorDetail = oldDoorDetail.copyWith(
      address: address,
      closedDoors: closedDoors,
      openedDoors: openedDoors,
      isCached: true,
    );
    return newDoorDetail;
  }

  PoiDetailModel toVirtualPoiDetailModel() {
    return PoiDetailModel.virtual(id: int.parse(id), status: PoiServiceType.door.name, location: location);
  }
}
