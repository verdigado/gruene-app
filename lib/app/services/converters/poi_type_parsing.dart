part of '../converters.dart';

extension PoiTypeParsing on PoiType {
  PoiServiceType toPoiServiceType() {
    switch (this) {
      case PoiType.flyerSpot:
        return PoiServiceType.flyer;
      case PoiType.poster:
        return PoiServiceType.poster;
      case PoiType.house:
        return PoiServiceType.door;
      case PoiType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
