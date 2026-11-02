import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<void> _revokeInvitation({
  required BuildContext context,
  required GuestInvitation invitation,
  required void Function(GuestInvitation invitation) onSuccess,
}) async {
  final revokeConfirmed = await showConfirmationDialog(
    context: context,
    title: t.guests.invitation.actions.revoke.title,
    content: t.guests.invitation.actions.revoke.description,
  );
  if (revokeConfirmed != true || !context.mounted) return;

  await tryAndNotify(
    function: () => GetIt.I<GuestApiService>().revokeInvitation(invitation.id),
    onSuccess: (context, _) {
      onSuccess(invitation.copyWith(status: GuestInvitationStatus.revoked));
      showSnackBar(
        context: context,
        text: t.guests.invitation.actions.revoke.success(email: invitation.email),
      );
    },
    getErrorMessage: (error) =>
        getErrorMessage(error, byStatusCode: {HttpStatus.conflict: t.guests.invitation.actions.revoke.error}),
    context: context,
  );
}

Future<GuestInvitation?> _resendInvitation({
  required BuildContext context,
  required GuestInvitation invitation,
  required void Function(GuestInvitation invitation) onSuccess,
}) => tryAndNotify(
  function: () => GetIt.I<GuestApiService>().resendInvitation(invitation.id),
  onSuccess: (context, invitation) {
    onSuccess(invitation);
    showSnackBar(
      context: context,
      text: t.guests.invitation.actions.resend.success(email: invitation.email),
    );
  },
  getErrorMessage: (error) =>
      getErrorMessage(error, byStatusCode: {HttpStatus.conflict: t.guests.invitation.actions.resend.error}),
  context: context,
);

extension GuestInvitationActionsExtension on GuestInvitation {
  List<ItemAction<GuestInvitation>> actions(BuildContext context) {
    final theme = Theme.of(context);
    if (status == GuestInvitationStatus.open) {
      return [
        ItemAction(
          label: t.guests.invitation.actions.resend.title,
          icon: Icons.send,
          primary: true,
          run: (onSuccess) => _resendInvitation(context: context, invitation: this, onSuccess: onSuccess),
        ),
        ItemAction(
          label: t.guests.invitation.actions.revoke.title,
          icon: Icons.block,
          color: theme.colorScheme.error,
          run: (onSuccess) => _revokeInvitation(context: context, invitation: this, onSuccess: onSuccess),
        ),
      ];
    }
    return [];
  }
}
