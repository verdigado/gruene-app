part of '../converters.dart';

extension PosterCreateModelParsing on PosterCreateModel {
  MarkerItemModel transformToVirtualMarkerItem(int temporaryId) {
    return MarkerItemModel.virtual(
      id: temporaryId,
      status: PoiServiceType.poster.getAsMarkerItemStatus(PosterStatus.ok),
      location: location,
    );
  }

  PosterDetailModel transformToPosterDetailModel(String temporaryId) {
    return PosterDetailModel(
      id: temporaryId,
      status: PosterStatus.ok,
      address: address,
      thumbnailUrl: imageFileLocation,
      imageUrl: imageFileLocation,
      location: location,
      comment: '',
      createdAt: '${DateTime.now().getAsLocalDateTimeString()}*', // should mark this as preliminary
      isCached: true,
    );
  }
}
