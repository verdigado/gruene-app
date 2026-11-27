part of '../converters.dart';

extension StandUpdateModelMapping on StandUpdateModel {
  PoiDetailModel toVirtualPoiDetailModel() {
    return PoiDetailModel.virtual(id: int.parse(id), status: PoiServiceType.stand.name, location: location);
  }

  StandDetailModel toStandDetailModel() {
    final photos = oldStandDetail.photos
        .where((photo) => !deletedPhotoIds.contains(photo.id))
        .where((photo) => !newPhotos.any((newPhoto) => newPhoto.id == photo.id))
        .toList();
    photos.addAll(newPhotos);

    return StandDetailModel(
      id: id,
      address: address,
      location: location,
      name: name,
      description: description,
      comment: comment,
      flyerCountTotal: oldStandDetail.flyerCountTotal,
      entries: oldStandDetail.entries,
      photos: photos,
      createdAt: oldStandDetail.createdAt,
      isCached: true,
    );
  }

  /// Combines two queued edits of the same stand: the newer values win, photo changes add up.
  StandUpdateModel mergeWith(StandUpdateModel newStandUpdate) {
    final newPhotos = [...this.newPhotos, ...newStandUpdate.newPhotos];
    final deletedPhotoIds = <String>[];
    for (final photoId in [...this.deletedPhotoIds, ...newStandUpdate.deletedPhotoIds]) {
      // a photo added and deleted again while offline is never uploaded
      if (newPhotos.any((photo) => photo.id == photoId)) {
        newPhotos.removeWhere((photo) => photo.id == photoId);
      } else {
        deletedPhotoIds.add(photoId);
      }
    }

    return StandUpdateModel(
      id: newStandUpdate.id,
      address: newStandUpdate.address,
      location: newStandUpdate.location,
      name: newStandUpdate.name,
      description: newStandUpdate.description,
      comment: newStandUpdate.comment,
      oldStandDetail: newStandUpdate.oldStandDetail,
      deletedPhotoIds: deletedPhotoIds,
      newPhotos: newPhotos,
    );
  }
}

extension StandDetailModelMapping on StandDetailModel {
  PoiDetailModel toVirtualPoiDetailModel() {
    return PoiDetailModel.virtual(id: int.parse(id), status: PoiServiceType.stand.name, location: location);
  }

  /// Adds the Termin, or replaces the one with the same id.
  StandDetailModel withEntry(StandEntryModel entry) =>
      copyWith(entries: [...entries.where((e) => e.id != entry.id), entry]);

  StandDetailModel withoutEntry(String entryId) => copyWith(entries: entries.where((e) => e.id != entryId).toList());
}
