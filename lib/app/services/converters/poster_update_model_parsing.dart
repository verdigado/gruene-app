part of '../converters.dart';

extension PosterUpdateModelParsing on PosterUpdateModel {
  PoiDetailModel transformToVirtualPoiDetailModel() {
    return PoiDetailModel.virtual(
      id: int.parse(id),
      status: PoiServiceType.poster.getAsMarkerItemStatus(status),
      location: location,
    );
  }

  PosterDetailModel transformToPosterDetailModel() {
    var photosConsolidated = oldPosterDetail.photos
        .where((x) => !deletedPhotoIds.contains(x.id))
        .where((x) => !newPhotos.any((n) => n.id == x.id))
        .toList();
    photosConsolidated.addAll(newPhotos);

    var newPosterDetail = oldPosterDetail.copyWith(
      status: status,
      address: address,
      photos: photosConsolidated,
      comment: comment,
      isCached: true,
    );
    return newPosterDetail;
  }

  PosterUpdateModel mergeWith(PosterUpdateModel newPosterUpdate) {
    var oldPosterUdpate = this;

    var newPhotosConsolidated = oldPosterUdpate.newPhotos.toList();
    newPhotosConsolidated.addAll(newPosterUpdate.newPhotos);

    var deletedPhotoIdsConsolidated = oldPosterUdpate.deletedPhotoIds.toList();
    deletedPhotoIdsConsolidated.addAll(newPosterUpdate.deletedPhotoIds);

    for (int i = 0; i < deletedPhotoIdsConsolidated.length; i++) {
      var deletedPhoto = deletedPhotoIdsConsolidated[i];
      if (newPhotosConsolidated.any((p) => p.id == deletedPhoto)) {
        newPhotosConsolidated.removeWhere((p) => p.id == deletedPhoto);
        deletedPhotoIdsConsolidated.remove(deletedPhoto);
        i--;
      }
    }

    return newPosterUpdate.copyWith(deletedPhotoIds: deletedPhotoIdsConsolidated, newPhotos: newPhotosConsolidated);
  }
}
