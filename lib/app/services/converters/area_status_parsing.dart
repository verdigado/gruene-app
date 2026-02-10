part of '../converters.dart';

extension AreaStatusParsing on AreaStatus {
  api_enums.UpdateAreaStatus asUpdateAreaStatus() {
    switch (this) {
      case AreaStatus.open:
        return api_enums.UpdateAreaStatus.open;
      case AreaStatus.closed:
        return api_enums.UpdateAreaStatus.closed;
      case AreaStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
