part of '../converters.dart';

extension TeamAssignmentTypeExtension on TeamAssignmentType {
  String getAssetLocationByAssignmentType() {
    switch (this) {
      case TeamAssignmentType.door:
        return 'assets/symbols/doors/door.svg';
      case TeamAssignmentType.flyer:
        return 'assets/symbols/flyer/flyer.svg';
      case TeamAssignmentType.poster:
        return 'assets/symbols/posters/poster.svg';
    }
  }
}
