part of '../mixins.dart';

mixin DoorValidator {
  ({int closedDoors, int openedDoors})? validateDoors(
    String openedDoorsRawValue,
    String closedDoorsRawValue,
    BuildContext context,
  ) {
    final openedDoors = int.tryParse(openedDoorsRawValue) ?? 0;
    final closedDoors = int.tryParse(closedDoorsRawValue) ?? 0;
    if (openedDoors + closedDoors == 0) {
      showToastError(context, t.campaigns.door.noDoorsWarning);
      return null;
    }
    return (closedDoors: closedDoors, openedDoors: openedDoors);
  }
}
