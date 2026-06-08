part of '../converters.dart';

extension AreaStatusParsing on AreaStatus {
  AreaStatus asUpdateAreaStatusStatus() {
    switch (this) {
      case AreaStatus.open:
        return AreaStatus.open;
      case AreaStatus.closed:
        return AreaStatus.closed;
      case AreaStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
