part of '../converters.dart';

extension PosterCreateModelParsing on PosterCreateModel {
  PoiDetailModel toVirtualPoiDetailModel(int temporaryId) {
    return PoiDetailModel.virtual(
      id: temporaryId,
      status: PoiServiceType.poster.toMarkerItemStatus(PosterModelStatus.ok),
      location: location,
    );
  }

  PosterDetailModel toPosterDetailModel(String temporaryId) {
    return PosterDetailModel(
      id: temporaryId,
      status: PosterModelStatus.ok,
      address: address,
      photos: imageFileLocation == null
          ? []
          : [
              PosterPhotoModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                imageUrl: imageFileLocation!,
                thumbnailUrl: imageFileLocation!,
                createdAt: DateTime.now(),
              ),
            ],
      location: location,
      comment: '',
      createdAt: '${DateTime.now().toLocalDateTimeString()}*', // should mark this as preliminary
      isCached: true,
    );
  }
}
