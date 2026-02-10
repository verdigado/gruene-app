part of '../mixins.dart';

mixin FlyerValidator {
  ({int flyerCount})? validateFlyer(String flyerCountRawValue, BuildContext context) {
    final flyerCount = int.tryParse(flyerCountRawValue) ?? 0;
    if (flyerCount < 1) {
      showToastError(context, t.campaigns.flyer.noFlyerWarning);
      return null;
    }
    return (flyerCount: flyerCount);
  }
}
