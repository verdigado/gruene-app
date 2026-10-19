part of '../converters.dart';

extension AreaStatusMapping on AreaStatus {
  AreaStatus toUpdateAreaStatusStatus() {
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
