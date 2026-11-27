import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_photo_model.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';

/// The photos of a pin while its form is open, newest first, and the changes to save.
class PhotoEditController extends ChangeNotifier {
  final List<PosterPhotoModel> _photos;
  final _newPhotos = <PosterPhotoModel>[];
  final _deletedPhotoIds = <String>[];

  /// [photos] are expected newest first.
  PhotoEditController([Iterable<PosterPhotoModel> photos = const []]) : _photos = photos.toList();

  List<PosterPhotoModel> get photos => List.unmodifiable(_photos);

  /// The photos saved before that were removed in the form.
  List<String> get deletedPhotoIds => List.unmodifiable(_deletedPhotoIds);

  bool get hasChanges => _newPhotos.isNotEmpty || _deletedPhotoIds.isNotEmpty;

  /// Adds [file] as the newest photo.
  void add(File file) {
    final now = DateTime.now();
    final photo = PosterPhotoModel(
      id: now.microsecondsSinceEpoch.toString(),
      imageUrl: file.absolute.path,
      thumbnailUrl: file.absolute.path,
      createdAt: now,
    );
    _newPhotos.add(photo);
    _photos.insert(0, photo);
    notifyListeners();
  }

  void removeAt(int index) => remove(_photos[index]);

  void remove(PosterPhotoModel photo) {
    if (!_photos.remove(photo)) return;
    // a photo added in this form was never saved, so it is just dropped
    if (!_newPhotos.remove(photo)) _deletedPhotoIds.add(photo.id);
    notifyListeners();
  }

  /// The photos added in the form, in the order they were added, made smaller and stored as local files that are
  /// uploaded later.
  Future<List<PosterPhotoModel>> prepareNewPhotos() async {
    if (_newPhotos.isEmpty) return [];
    // gives a loading indicator the time to show before the images are processed
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final prepared = <PosterPhotoModel>[];
    for (final photo in _newPhotos) {
      final reducedImage = await MediaHelper.resizeAndReduceImageFile(File(photo.imageUrl));
      final fileLocation = await MediaHelper.storeImage(reducedImage!);
      prepared.add(photo.copyWith(imageUrl: fileLocation, thumbnailUrl: fileLocation));
    }
    return prepared;
  }
}
