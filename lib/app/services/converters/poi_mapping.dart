part of '../converters.dart';

extension PoiMapping on Poi {
  PoiDetailModel toMarkerItem() {
    final poi = this;
    String statusSuffix = '';
    if (poi.poster != null) statusSuffix = '_${poi.poster!.status.name}';
    return PoiDetailModel(
      id: int.parse(poi.id),
      location: poi.coords.toLatLng(),
      status: '${poi.type.toPoiServiceType().name}$statusSuffix',
    );
  }

  DoorDetailModel toDoorDetail() {
    final poi = this;
    if (poi.type != PoiType.house) {
      throw Exception('Unexpected PoiType');
    }
    return DoorDetailModel(
      id: poi.id,
      address: poi.address.toAddressModel(),
      conversations: poi.house!.countConversations.toInt(),
      materialOnly: poi.house!.countMaterialOnly.toInt(),
      location: poi.coords.toLatLng(),
      createdAt: poi.createdAt.toLocalDateTimeString(),
    );
  }

  StandDetailModel toStandDetail() {
    final poi = this;
    if (poi.type != PoiType.stand) {
      throw Exception('Unexpected PoiType');
    }
    final stand = poi.stand!;
    return StandDetailModel(
      id: poi.id,
      address: poi.address.toAddressModel(),
      location: poi.coords.toLatLng(),
      name: stand.name,
      description: stand.description,
      comment: stand.comment,
      flyerCountTotal: stand.flyerCountTotal.toInt(),
      entries: stand.entries.map((entry) => entry.toStandEntry()).toList(),
      photos: _getPosterPhotos(),
      createdAt: poi.createdAt.toLocalDateTimeString(),
    );
  }

  PosterDetailModel toPosterDetail() {
    final poi = this;
    if (poi.type != PoiType.poster) {
      throw Exception('Unexpected PoiType');
    }
    return PosterDetailModel(
      id: poi.id,
      photos: _getPosterPhotos(),
      address: poi.address.toAddressModel(),
      status: poi.poster!.status.toModelPosterStatus(),
      location: coords.toLatLng(),
      comment: poi.poster!.comment.safe(),
      createdAt: poi.createdAt.toLocalDateTimeString(),
    );
  }

  PosterListItemModel toPosterListItem() {
    final poi = this;
    if (poi.type != PoiType.poster) {
      throw Exception('Unexpected PoiType');
    }

    return PosterListItemModel(
      id: poi.id,
      thumbnailUrl: _getLatestThumbnailImageUrl(),
      imageUrl: _getLatestImageUrl(),
      address: poi.address.toAddressModel(),
      status: poi.poster!.status.translatePosterStatus(),
      lastChangeStatus: poi._getLastChangeStatus(),
      lastChangeDateTime: poi.updatedAt.toLocalDateTimeString(),
      createdAt: poi.createdAt,
    );
  }

  String _getLastChangeStatus() {
    return createdAt == updatedAt ? t.campaigns.poster.created : t.campaigns.poster.updated;
  }

  List<PosterPhotoModel> _getPosterPhotos() {
    return photos.map((x) => x.toPosterPhoto()).toList();
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

extension on PoiStandEntry {
  StandEntryModel toStandEntry() =>
      StandEntryModel(id: id, startAt: startAt.toLocal(), endAt: endAt.toLocal(), flyerCount: flyerCount.toInt());
}

extension on ImageSrcSet {
  PosterPhotoModel toPosterPhoto() {
    return PosterPhotoModel(
      id: id,
      imageUrl: original.url,
      thumbnailUrl: srcset.where((x) => x.type == 'thumbnail').first.url,
      createdAt: DateTime.now(),
    );
  }
}
