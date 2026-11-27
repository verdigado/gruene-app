part of '../converters.dart';

extension PoiTypeMapping on PoiType {
  PoiServiceType toPoiServiceType() {
    switch (this) {
      case PoiType.poster:
        return PoiServiceType.poster;
      case PoiType.house:
        return PoiServiceType.door;
      case PoiType.stand:
        return PoiServiceType.stand;
      case PoiType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
