part of '../converters.dart';

extension PoiParsing on Poi {
  MarkerItemModel transformToMarkerItem() {
    final poi = this;
    String statusSuffix = '';
    if (poi.poster != null) statusSuffix = '_${poi.poster!.status.name}';
    return MarkerItemModel(
      id: int.parse(poi.id),
      location: poi.coords.transformToLatLng(),
      status: '${poi.type.transformToPoiServiceType().name}$statusSuffix',
    );
  }

  DoorDetailModel transformPoiToDoorDetail() {
    final poi = this;
    if (poi.type != PoiType.house) {
      throw Exception('Unexpected PoiType');
    }
    return DoorDetailModel(
      id: poi.id,
      address: poi.address.transformToAddressModel(),
      openedDoors: poi.house!.countOpenedDoors.toInt(),
      closedDoors: poi.house!.countClosedDoors.toInt(),
      location: poi.coords.transformToLatLng(),
      createdAt: poi.createdAt.getAsLocalDateTimeString(),
    );
  }

  PosterDetailModel transformPoiToPosterDetail() {
    final poi = this;
    if (poi.type != PoiType.poster) {
      throw Exception('Unexpected PoiType');
    }
    return PosterDetailModel(
      id: poi.id,
      photos: _getPosterPhotos(),
      address: poi.address.transformToAddressModel(),
      status: poi.poster!.status.transformToModelPosterStatus(),
      location: coords.transformToLatLng(),
      comment: poi.poster!.comment ?? '',
      createdAt: poi.createdAt.getAsLocalDateTimeString(),
    );
  }

  FlyerDetailModel transformPoiToFlyerDetail() {
    final poi = this;
    if (poi.type != PoiType.flyerSpot) {
      throw Exception('Unexpected PoiType');
    }
    return FlyerDetailModel(
      id: poi.id,
      address: poi.address.transformToAddressModel(),
      flyerCount: poi.flyerSpot!.flyerCount.toInt(),
      createdAt: poi.createdAt.getAsLocalDateTimeString(),
      location: coords.transformToLatLng(),
    );
  }

  PosterListItemModel transformToPosterListItem() {
    final poi = this;
    if (poi.type != PoiType.poster) {
      throw Exception('Unexpected PoiType');
    }

    return PosterListItemModel(
      id: poi.id,
      thumbnailUrl: _getLatestThumbnailImageUrl(),
      imageUrl: _getLatestImageUrl(),
      address: poi.address.transformToAddressModel(),
      status: poi.poster!.status.translatePosterStatus(),
      lastChangeStatus: poi._getLastChangeStatus(),
      lastChangeDateTime: poi.updatedAt.getAsLocalDateTimeString(),
      createdAt: poi.createdAt,
    );
  }

  String _getLastChangeStatus() {
    return createdAt == updatedAt ? t.campaigns.poster.created : t.campaigns.poster.updated;
  }

  List<PosterPhotoModel> _getPosterPhotos() {
    return photos.map((x) => x.getAsPosterPhoto()).toList();
  }

  String? _getLatestThumbnailImageUrl() {
    var poi = this;
    if (poi.photos.isEmpty) {
      return null;
    }
    var photos = _getPosterPhotos();
    photos.sortByIdDescending();
    return photos.first.thumbnailUrl;
  }

  String? _getLatestImageUrl() {
    var poi = this;
    if (poi.photos.isEmpty) {
      return null;
    }

    var photos = _getPosterPhotos();
    photos.sortByIdDescending();
    return photos.first.imageUrl;
  }
}

extension on ImageSrcSet {
  PosterPhotoModel getAsPosterPhoto() {
    return PosterPhotoModel(
      id: id,
      imageUrl: original.url,
      thumbnailUrl: srcset.where((x) => x.type == 'thumbnail').first.url,
      createdAt: DateTime.now(),
    );
  }
}
