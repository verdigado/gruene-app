part of '../converters.dart';

extension PoiServiceTypeMapping on PoiServiceType {
  PoiType toApiPoisType() {
    switch (this) {
      case PoiServiceType.poster:
        return PoiType.poster;
      case PoiServiceType.door:
        return PoiType.house;
      case PoiServiceType.stand:
        return PoiType.stand;
    }
  }

  List<AreaType> toApiAreasGetTypes() {
    switch (this) {
      // flyer action areas are shown in the door tab
      case PoiServiceType.door:
        return [AreaType.house, AreaType.flyerSpot];
      case PoiServiceType.poster:
        return [AreaType.poster];
      case PoiServiceType.stand:
        throw UnsupportedError('The stand tab shows no action areas');
    }
  }

  String toMarkerItemStatus(PosterModelStatus? posterStatus) {
    var typeName = name;
    switch (this) {
      case PoiServiceType.poster:
        String statusSuffix = '';
        if (posterStatus != null) statusSuffix = '_${posterStatus.name}';
        return '$typeName$statusSuffix';
      case PoiServiceType.door:
      case PoiServiceType.stand:
        return typeName;
    }
  }

  List<RouteType> toRoutesApiGetTypes() {
    switch (this) {
      case PoiServiceType.poster:
        return [RouteType.poster];
      // flyer routes are shown in the door tab
      case PoiServiceType.door:
        return [RouteType.house, RouteType.flyerSpot];
      case PoiServiceType.stand:
        throw UnsupportedError('The stand tab shows no routes');
    }
  }

  PoiCacheType toPoiCacheType() {
    switch (this) {
      case PoiServiceType.poster:
        return PoiCacheType.poster;
      case PoiServiceType.door:
        return PoiCacheType.door;
      case PoiServiceType.stand:
        // TODO #1266: stands are cached for offline use with the stand offline queue
        throw UnimplementedError();
    }
  }
}
