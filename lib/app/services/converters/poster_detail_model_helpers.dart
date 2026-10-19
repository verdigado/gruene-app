part of '../converters.dart';

extension PosterDetailModelHelpers on PosterDetailModel {
  PosterPhotoModel? latestPhoto() {
    if (photos.isEmpty) return null;
    photos.sortByIdDescending();
    return photos.first;
  }

  PosterUpdateModel toPosterUpdate() {
    return PosterUpdateModel(
      id: id,
      address: address,
      status: status,
      comment: comment,
      location: location,
      oldPosterDetail: this,
      deletedPhotoIds: [],
      newPhotos: [],
    );
  }
}
