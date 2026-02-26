part of '../converters.dart';

extension AreaStatusParsing on AreaStatus {
  api_enums.UpdateAreaStatusStatus asUpdateAreaStatusStatus() {
    switch (this) {
      case AreaStatus.open:
        return api_enums.UpdateAreaStatusStatus.open;
      case AreaStatus.closed:
        return api_enums.UpdateAreaStatusStatus.closed;
      case AreaStatus.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
