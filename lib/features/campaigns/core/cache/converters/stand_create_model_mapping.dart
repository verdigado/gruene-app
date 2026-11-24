part of '../converters.dart';

extension StandCreateModelMapping on StandCreateModel {
  PoiDetailModel toVirtualPoiDetailModel(int temporaryId) {
    return PoiDetailModel.virtual(id: temporaryId, status: PoiServiceType.stand.name, location: location);
  }

  StandCreateModel withFirstEntry(StandEntryCreateModel firstEntry) => StandCreateModel(
    location: location,
    address: address,
    name: name,
    description: description,
    comment: comment,
    firstEntry: firstEntry,
    imageFileLocations: imageFileLocations,
    campaignId: campaignId,
  );

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
      photos: imageFileLocations
          .map((file) => PosterPhotoModel(id: file, imageUrl: file, thumbnailUrl: file, createdAt: DateTime.now()))
          .toList(),
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
