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
      final theme = Theme.of(context);
      MotionToast.error(
        description: Text(
          t.campaigns.door.noDoorsWarning,
          style: theme.textTheme.labelMedium!.apply(color: ThemeColors.background),
        ),
      ).show(context);
      return null;
    }
    return (closedDoors: closedDoors, openedDoors: openedDoors);
  }
}
