part of '../mixins.dart';

mixin FlyerValidator {
  ({int flyerCount})? validateFlyer(String flyerCountRawValue, BuildContext context) {
    final flyerCount = int.tryParse(flyerCountRawValue) ?? 0;
    if (flyerCount < 1) {
      final theme = Theme.of(context);
      MotionToast.error(
        description: Text(
          t.campaigns.flyer.noFlyerWarning,
          style: theme.textTheme.labelMedium!.apply(color: ThemeColors.background),
        ),
      ).show(context);
      return null;
    }
    return (flyerCount: flyerCount);
  }
}
