part of '../converters.dart';

extension PosterCreateModelParsing on PosterCreateModel {
  PoiDetailModel transformToVirtualPoiDetailModel(int temporaryId) {
    return PoiDetailModel.virtual(
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
      createdAt: '${DateTime.now().getAsLocalDateTimeString()}*', // should mark this as preliminary
      isCached: true,
    );
  }
}
