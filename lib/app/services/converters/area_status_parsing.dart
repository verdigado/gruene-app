part of '../converters.dart';

extension AreaStatusParsing on AreaStatus {
  UpdateAreaStatus asUpdateAreaStatus() {
    switch (this) {
      case AreaStatus.open:
        return UpdateAreaStatus.open;
      case AreaStatus.assigned:
        return UpdateAreaStatus.assigned;
      case AreaStatus.closed:
        return UpdateAreaStatus.closed;
      case AreaStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
