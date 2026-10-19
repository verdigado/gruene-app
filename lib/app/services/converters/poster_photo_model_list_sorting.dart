part of '../converters.dart';

extension PosterPhotoModelListSorting on List<PosterPhotoModel> {
  void sortByIdDescending() {
    sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id))); // reverse sorting
  }
}
