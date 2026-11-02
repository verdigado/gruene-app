import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

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
      text: t.guests.actions.renew.success(
        name: guest.fullName,
        date: guest.expiresAt?.formattedDate ?? t.common.unknown,
      ),
    );
  },
  getErrorMessage: (error) => getErrorMessage(error, byStatusCode: {HttpStatus.conflict: t.guests.actions.renew.error}),
  context: context,
);

Future<void> _blockGuest({
  required BuildContext context,
  required Guest guest,
  required void Function(Guest guest) onSuccess,
}) async {
  final blockConfirmed = await showConfirmationDialog(
    context: context,
    title: t.guests.actions.block.title,
    content: t.guests.actions.block.description(name: guest.fullName),
  );
  if (blockConfirmed != true || !context.mounted) return;

  await tryAndNotify(
    function: () => GetIt.I<GuestApiService>().blockGuest(guest.userId),
    onSuccess: (context, guest) {
      onSuccess(guest);
      showSnackBar(
        context: context,
        text: t.guests.actions.block.success(name: guest.fullName),
      );
    },
    getErrorMessage: (error) =>
        getErrorMessage(error, byStatusCode: {HttpStatus.conflict: t.guests.actions.block.error}),
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
    title: t.guests.actions.unblock.title,
    content: t.guests.actions.unblock.description(name: guest.fullName),
  );
  if (unblockConfirmed != true || !context.mounted) return;

  await tryAndNotify(
    function: () => GetIt.I<GuestApiService>().unblockGuest(guest.userId),
    onSuccess: (context, guest) {
      onSuccess(guest);
      showSnackBar(
        context: context,
        text: t.guests.actions.unblock.success(name: guest.fullName),
      );
    },
    getErrorMessage: (error) =>
        getErrorMessage(error, byStatusCode: {HttpStatus.conflict: t.guests.actions.unblock.error}),
    context: context,
  );
}

extension GuestActionsExtension on Guest {
  List<ItemAction<Guest>> actions(BuildContext context) {
    final theme = Theme.of(context);
    return [
      if (status == GuestStatus.active)
        ItemAction(
          label: t.guests.actions.renew.title,
          icon: Icons.more_time,
          primary: true,
          run: (onSuccess) => _renewGuest(context: context, guest: this, onSuccess: onSuccess),
        ),
      if (status != GuestStatus.blocked)
        ItemAction(
          label: t.guests.actions.block.title,
          icon: Icons.block,
          color: theme.colorScheme.error,
          run: (onSuccess) => _blockGuest(context: context, guest: this, onSuccess: onSuccess),
        ),
      if (status == GuestStatus.blocked)
        ItemAction(
          label: t.guests.actions.unblock.title,
          icon: Icons.lock_open,
          color: theme.colorScheme.error,
          run: (onSuccess) => _unblockGuest(context: context, guest: this, onSuccess: onSuccess),
        ),
    ];
  }
}
