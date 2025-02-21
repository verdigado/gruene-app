part of '../converters.dart';

extension PosterDetailModelExtension on PosterDetailModel {
  PosterPhotoModel? latestPhoto() {
    if (photos.isEmpty) return null;
    photos.sortByIdDescending();
    return photos.first;
  }

  PosterUpdateModel asPosterUpdate() {
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

extension PosterPhotoModelListExtension on List<PosterPhotoModel> {
  void sortByIdDescending() {
    sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id))); // reverse sorting
  }
}
