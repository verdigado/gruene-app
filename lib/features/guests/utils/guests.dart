import 'package:flutter/material.dart' hide Action;
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension GuestStatusExtension on GuestStatus {
  String get label => switch (this) {
    GuestStatus.active => t.guests.status.active,
    GuestStatus.blocked => t.guests.status.blocked,
    GuestStatus.expired => t.guests.status.expired,
    GuestStatus.swaggerGeneratedUnknown => t.common.unknown,
  };
}

extension GuestHistoryTypeExtension on GuestHistoryType {
  String get label => switch (this) {
    GuestHistoryType.invited => t.guests.history.invited,
    GuestHistoryType.accepted => t.guests.history.accepted,
    GuestHistoryType.renewed => t.guests.history.renewed,
    GuestHistoryType.expired => t.guests.history.expired,
    GuestHistoryType.blocked => t.guests.history.blocked,
    GuestHistoryType.unblocked => t.guests.history.unblocked,
    GuestHistoryType.swaggerGeneratedUnknown => t.common.unknown,
  };
}

Future<Guest?> _renewGuest({
  required BuildContext context,
  required Guest guest,
  required void Function(Guest guest) onSuccess,
}) => tryAndNotify(
  function: () => GetIt.I<GuestApiService>().renewGuest(guest.userId),
  onSuccess: (context, guest) {
    onSuccess(guest);
    showSnackBar(
      context: context,
      text: t.guests.renew.success(name: guest.fullName, date: guest.expiresOn?.formattedDate ?? t.common.unknown),
    );
  },
  getErrorMessage: (error) => guestErrorMessage(error, byStatusCode: {409: t.guests.error.guestBlocked}),
  context: context,
);

Future<void> _blockGuest({
  required BuildContext context,
  required Guest guest,
  required void Function(Guest guest) onSuccess,
}) async {
  final blockConfirmed = await showConfirmationDialog(
    context: context,
    title: t.guests.block.title,
    content: t.guests.block.description(name: guest.fullName),
  );
  if (blockConfirmed != true || !context.mounted) return;

  await tryAndNotify(
    function: () => GetIt.I<GuestApiService>().blockGuest(guest.userId),
    onSuccess: (context, guest) {
      onSuccess(guest);
      showSnackBar(
        context: context,
        text: t.guests.block.success(name: guest.fullName),
      );
    },
    getErrorMessage: (error) => guestErrorMessage(error, byStatusCode: {409: t.guests.error.alreadyBlocked}),
    context: context,
  );
}

Future<void> _unblockGuest({
  required BuildContext context,
  required Guest guest,
  required void Function(Guest guest) onSuccess,
}) async {
  final unblockConfirmed = await showConfirmationDialog(
    context: context,
    title: t.guests.unblock.title,
    content: t.guests.unblock.description(name: guest.fullName),
  );
  if (unblockConfirmed != true || !context.mounted) return;

  await tryAndNotify(
    function: () => GetIt.I<GuestApiService>().unblockGuest(guest.userId),
    onSuccess: (context, guest) {
      onSuccess(guest);
      showSnackBar(
        context: context,
        text: t.guests.unblock.success(name: guest.fullName),
      );
    },
    getErrorMessage: (error) => guestErrorMessage(error, byStatusCode: {409: t.guests.error.notBlocked}),
    context: context,
  );
}

extension GuestExtension on Guest {
  String get fullName => '$firstName $lastName';

  bool matches(String query) {
    final term = query.trim().toLowerCase();
    return term.isEmpty || fullName.toLowerCase().contains(term) || (email?.toLowerCase().contains(term) ?? false);
  }

  List<Action<Guest>> actions(BuildContext context) {
    final theme = Theme.of(context);
    return [
      if (status == GuestStatus.active)
        // TODO renew if not expired for too long?
        Action(
          label: t.guests.renew.title,
          icon: Icons.more_time,
          primary: true,
          action: (onSuccess) => _renewGuest(context: context, guest: this, onSuccess: onSuccess),
        ),
      status == GuestStatus.blocked
          ? Action(
              label: t.guests.unblock.title,
              icon: Icons.lock_open,
              color: theme.colorScheme.error,
              action: (onSuccess) => _unblockGuest(context: context, guest: this, onSuccess: onSuccess),
            )
          : Action(
              label: t.guests.block.title,
              icon: Icons.block,
              color: theme.colorScheme.error,
              action: (onSuccess) => _blockGuest(context: context, guest: this, onSuccess: onSuccess),
            ),
    ];
  }
}

extension GuestDetailExtension on GuestDetail {
  String get fullName => '$firstName $lastName';

  Guest toGuest() => Guest(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    divisionKey: divisionKey,
    status: status,
    expiresOn: expiresOn,
  );
}
