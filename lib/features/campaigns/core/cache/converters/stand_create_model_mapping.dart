part of '../converters.dart';

extension StandCreateModelMapping on StandCreateModel {
  PoiDetailModel toVirtualPoiDetailModel(int temporaryId) {
    return PoiDetailModel.virtual(id: temporaryId, status: PoiServiceType.stand.name, location: location);
  }

  StandCreateModel withFirstEntry(StandEntryCreateModel firstEntry) =>
      _copyWith(firstEntry: firstEntry, imageFileLocations: imageFileLocations);

  StandCreateModel withImageFileLocations(List<String> imageFileLocations) =>
      _copyWith(firstEntry: firstEntry, imageFileLocations: imageFileLocations);

  StandCreateModel _copyWith({required StandEntryCreateModel firstEntry, required List<String> imageFileLocations}) =>
      StandCreateModel(
        location: location,
        address: address,
        name: name,
        description: description,
        comment: comment,
        firstEntry: firstEntry,
        imageFileLocations: imageFileLocations,
        campaignId: campaignId,
      );

  /// The photos as long as they are only in the queue: their id is their local file. [imageFileLocations] are
  /// oldest first, which their dates keep.
  List<PosterPhotoModel> toQueuedPhotos() {
    final now = DateTime.now();
    return [
      for (final (index, file) in imageFileLocations.indexed)
        PosterPhotoModel(
          id: file,
          imageUrl: file,
          thumbnailUrl: file,
          createdAt: now.add(Duration(milliseconds: index)),
        ),
    ];
  }

  /// The stand as long as it is only in the queue. Its flyer total comes from the API after the sync.
  StandDetailModel toStandDetailModel(String temporaryId, {required String firstEntryId}) {
    return StandDetailModel(
      id: temporaryId,
      address: address,
      location: location,
      name: name,
      description: description,
      comment: comment,
      flyerCountTotal: 0,
      entries: [firstEntry.toStandEntryModel(firstEntryId)],
      photos: toQueuedPhotos(),
      createdAt: '${DateTime.now().toLocalDateTimeString()}*', // should mark this as preliminary
      isCached: true,
    );
  }
}

extension StandEntryCreateModelMapping on StandEntryCreateModel {
  StandEntryModel toStandEntryModel(String id) =>
      StandEntryModel(id: id, startAt: startAt, endAt: endAt, flyerCount: flyerCount ?? 0);
}

extension StandEntryUpdateModelMapping on StandEntryUpdateModel {
  StandEntryModel toStandEntryModel() =>
      StandEntryModel(id: entryId, startAt: startAt, endAt: endAt, flyerCount: flyerCount ?? 0);
}
