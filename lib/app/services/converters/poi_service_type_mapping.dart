part of '../converters.dart';

extension PoiServiceTypeMapping on PoiServiceType {
  PoiType toApiPoisType() {
    switch (this) {
      case PoiServiceType.poster:
        return PoiType.poster;
      case PoiServiceType.door:
        return PoiType.house;
      case PoiServiceType.flyer:
        return PoiType.flyerSpot;
    }
  }

  AreaType toApiAreasGetType() {
    switch (this) {
      case PoiServiceType.door:
        return AreaType.house;
      case PoiServiceType.flyer:
        return AreaType.flyerSpot;
      case PoiServiceType.poster:
        return AreaType.poster;
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
      case PoiServiceType.flyer:
        return typeName;
    }
  }

  RouteType toRoutesApiGetType() {
    switch (this) {
      case PoiServiceType.poster:
        return RouteType.poster;
      case PoiServiceType.door:
        return RouteType.house;
      case PoiServiceType.flyer:
        return RouteType.flyerSpot;
    }
  }

  PoiCacheType toPoiCacheType() {
    switch (this) {
      case PoiServiceType.poster:
        return PoiCacheType.poster;
      case PoiServiceType.door:
        return PoiCacheType.door;
      case PoiServiceType.flyer:
        return PoiCacheType.flyer;
    }
  }
}
