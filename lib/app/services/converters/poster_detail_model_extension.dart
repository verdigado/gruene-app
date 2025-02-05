part of '../converters.dart';

extension PosterDetailModelExtension on PosterDetailModel {
  PosterPhotoModel? latestPhoto() {
    if (photos.isEmpty) return null;
    photos.sortByIdDescending();
    return photos.first;
  }
}

extension PosterPhotoModelListExtension on List<PosterPhotoModel> {
  void sortByIdDescending() {
    sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id))); // reverse sorting
  }
}
