import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_photo_model.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/photo_edit_controller.dart';

PosterPhotoModel _savedPhoto(String id) => PosterPhotoModel(
  id: id,
  imageUrl: 'https://img/$id.jpg',
  thumbnailUrl: 'https://img/$id.jpg',
  createdAt: DateTime(2026),
);

void main() {
  test('shows the saved photos and has no changes at first', () {
    final controller = PhotoEditController([_savedPhoto('2'), _savedPhoto('1')]);

    expect(controller.photos.map((p) => p.id), ['2', '1']);
    expect(controller.hasChanges, isFalse);
    expect(controller.deletedPhotoIds, isEmpty);
  });

  test('a new photo comes first', () {
    final controller = PhotoEditController([_savedPhoto('1')]);

    controller.add(File('/photos/new.jpg'));

    expect(controller.photos.first.imageUrl, File('/photos/new.jpg').absolute.path);
    expect(controller.photos, hasLength(2));
    expect(controller.hasChanges, isTrue);
  });

  test('removing a saved photo deletes it, the others stay', () {
    final controller = PhotoEditController([_savedPhoto('2'), _savedPhoto('1')]);

    controller.removeAt(0);

    expect(controller.photos.map((p) => p.id), ['1']);
    expect(controller.deletedPhotoIds, ['2']);
    expect(controller.hasChanges, isTrue);
  });

  test('a photo added and removed again in the form is just dropped', () async {
    final controller = PhotoEditController([_savedPhoto('1')]);

    controller.add(File('/photos/new.jpg'));
    controller.removeAt(0);

    expect(controller.photos.map((p) => p.id), ['1']);
    expect(controller.deletedPhotoIds, isEmpty);
    expect(controller.hasChanges, isFalse);
    expect(await controller.prepareNewPhotos(), isEmpty);
  });

  test('tells its listeners about changes', () {
    final controller = PhotoEditController([_savedPhoto('1')]);
    var notified = 0;
    controller.addListener(() => notified++);

    controller.add(File('/photos/new.jpg'));
    controller.removeAt(1);

    expect(notified, 2);
  });
}
