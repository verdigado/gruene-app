import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

enum GuestAction {
  renew,
  block,
  unblock;

  static List<GuestAction> availableFor(GuestStatus status) => switch (status) {
    GuestStatus.active => [renew, block],
    GuestStatus.blocked => [unblock],
    _ => [],
  };

  String get label => switch (this) {
    renew => t.guests.renew,
    block => t.guests.block,
    unblock => t.guests.unblock,
  };

  String? get hint => this == block ? t.guests.blockHint : null;

  IconData get icon => switch (this) {
    renew => Icons.more_time,
    block => Icons.block,
    unblock => Icons.lock_open,
  };

  /// Shows the outcome and returns the updated guest, or `null` if it was cancelled or failed. [onConfirmed] runs right
  /// before the request, after any confirmation.
  Future<Guest?> run(BuildContext context, Guest guest, {void Function()? onConfirmed}) async {
    final service = GetIt.I<GuestApiService>();
    if (this == block && (await _confirmBlock(context, guest) != true || !context.mounted)) return null;
    onConfirmed?.call();
    switch (this) {
      case renew:
        return _request(
          context,
          () => service.renewGuest(guest.userId),
          success: (updated) =>
              t.guests.renewedUntil(name: guest.fullName, date: updated.expiresOn?.formattedDate ?? t.common.unknown),
          conflict: t.guests.error.guestBlocked,
        );
      case block:
        return _request(
          context,
          () => service.blockGuest(guest.userId),
          success: (_) => t.guests.blocked(name: guest.fullName),
          conflict: t.guests.error.alreadyBlocked,
        );
      case unblock:
        return _request(
          context,
          () => service.unblockGuest(guest.userId),
          success: (_) => t.guests.unblocked(name: guest.fullName),
          conflict: t.guests.error.notBlocked,
        );
    }
  }
}

Future<Guest?> _request(
  BuildContext context,
  Future<Guest> Function() request, {
  required String Function(Guest updated) success,
  required String conflict,
}) async {
  try {
    final updated = await request();
    if (context.mounted) showSnackBar(context: context, text: success(updated));
    return updated;
  } catch (error) {
    if (context.mounted) {
      showSnackBar(
        context: context,
        text: guestErrorMessage(error, byStatusCode: {403: t.guests.error.forbidden, 409: conflict}),
      );
    }
    return null;
  }
}

Future<bool?> _confirmBlock(BuildContext context, Guest guest) => showDialog<bool>(
  context: context,
  builder: (context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(t.guests.confirmBlock.title, style: theme.textTheme.titleLarge),
      content: Text(t.guests.confirmBlock.text(name: guest.fullName)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: EdgeInsets.all(8),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.common.actions.cancel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(t.guests.confirmBlock.confirm, style: TextStyle(color: theme.colorScheme.error)),
        ),
      ],
    );
  },
);
