part of '../converters.dart';

extension PosterUpdateModelParsing on PosterUpdateModel {
  MarkerItemModel transformToVirtualMarkerItem() {
    return MarkerItemModel.virtual(
      id: int.parse(id),
      status: PoiServiceType.poster.getAsMarkerItemStatus(status),
      location: location,
    );
  }

  PosterDetailModel transformToPosterDetailModel() {
    var newPosterDetail = oldPosterDetail.copyWith(
      status: status,
      address: address,
      thumbnailUrl: newImageFileLocation ?? (!removePreviousPhotos ? oldPosterDetail.thumbnailUrl : null),
      imageUrl: newImageFileLocation ?? (!removePreviousPhotos ? oldPosterDetail.imageUrl : null),
      comment: comment,
      isCached: true,
    );
    return newPosterDetail;
  }

  PosterUpdateModel mergeWith(PosterUpdateModel newPosterUpdate) {
    var oldPosterUdpate = this;

    return newPosterUpdate.copyWith(
      removePreviousPhotos: newPosterUpdate.removePreviousPhotos || oldPosterUdpate.removePreviousPhotos,
    );
  }
}
