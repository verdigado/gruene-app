part of '../converters.dart';

extension DoorCreateModelParsing on DoorCreateModel {
  DoorDetailModel transformToDoorDetailModel(String temporaryId) {
    return DoorDetailModel(
      id: temporaryId,
      address: address,
      closedDoors: closedDoors,
      openedDoors: openedDoors,
      location: location,
      createdAt: '${DateTime.now().getAsLocalDateTimeString()}*', // should mark this as preliminary
      isCached: true,
    );
  }

  MarkerItemModel transformToVirtualMarkerItem(int temporaryId) {
    return MarkerItemModel.virtual(
      id: temporaryId,
      status: PoiServiceType.door.name,
      location: location,
    );
  }
}
