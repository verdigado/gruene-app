part of '../converters.dart';

extension DoorUpdateModelParsing on DoorUpdateModel {
  DoorDetailModel transformToDoorDetailModel() {
    var newDoorDetail = oldDoorDetail.copyWith(
      address: address,
      closedDoors: closedDoors,
      openedDoors: openedDoors,
      isCached: true,
    );
    return newDoorDetail;
  }

  MarkerItemModel transformToVirtualMarkerItem() {
    return MarkerItemModel.virtual(
      id: int.parse(id),
      status: PoiServiceType.door.name,
      location: location,
    );
  }
}
