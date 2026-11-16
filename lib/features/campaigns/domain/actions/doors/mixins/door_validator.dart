part of '../mixins.dart';

/// Mixin for validating door-related input
mixin DoorValidator {
  ({int materialOnly, int conversations})? validateDoors(
    String conversationsRawValue,
    String materialOnlyRawValue,
    BuildContext context,
  ) {
    final conversations = int.tryParse(conversationsRawValue) ?? 0;
    final materialOnly = int.tryParse(materialOnlyRawValue) ?? 0;
    if (conversations + materialOnly == 0) {
      showToastError(context, t.campaigns.door.noDoorsWarning);
      return null;
    }
    return (materialOnly: materialOnly, conversations: conversations);
  }
}
