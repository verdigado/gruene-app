part of '../converters.dart';

extension PoiTypeMapping on PoiType {
  PoiServiceType toPoiServiceType() {
    switch (this) {
      case PoiType.poster:
        return PoiServiceType.poster;
      case PoiType.house:
        return PoiServiceType.door;
      case PoiType.stand:
        // TODO #1266: map the new pin type STAND to PoiServiceType.stand
        throw UnimplementedError();
      case PoiType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
