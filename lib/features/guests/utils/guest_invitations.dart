import 'package:flutter/material.dart' hide Action;
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension GuestInvitationStatusExtension on GuestInvitationStatus {
  String get label => switch (this) {
    GuestInvitationStatus.open => t.guests.invitation.status.open,
    GuestInvitationStatus.accepted => t.guests.invitation.status.accepted,
    GuestInvitationStatus.expired => t.guests.invitation.status.expired,
    GuestInvitationStatus.revoked => t.guests.invitation.status.revoked,
    GuestInvitationStatus.swaggerGeneratedUnknown => t.common.unknown,
  };
}

// TODO remove redundant errors that never happen
String guestErrorMessage(Object error, {Map<int, String> byStatusCode = const {}}) {
  final message = error is ApiException ? byStatusCode[error.statusCode] : null;
  return message ?? getErrorMessage(error, defaultMessage: t.guests.error.failed);
}

Future<void> _revokeInvitation({
  required BuildContext context,
  required GuestInvitation invitation,
  required void Function(GuestInvitation invitation) onSuccess,
}) async {
  final revokeConfirmed = await showConfirmationDialog(
    context: context,
    title: t.guests.invitation.revoke.title,
    content: t.guests.invitation.revoke.description,
  );
  if (revokeConfirmed != true || !context.mounted) return;

  await tryAndNotify(
    function: () => GetIt.I<GuestApiService>().revokeInvitation(invitation.id),
    onSuccess: (context, _) {
      onSuccess(invitation.copyWith(status: GuestInvitationStatus.revoked));
      showSnackBar(context: context, text: t.guests.invitation.revoke.success(email: invitation.email));
    },
    getErrorMessage: (error) => guestErrorMessage(error, byStatusCode: {409: t.guests.error.notOpen}),
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
      text: t.guests.invitation.resend.success(email: invitation.email),
    );
  },
  getErrorMessage: (error) => guestErrorMessage(error, byStatusCode: {409: t.guests.error.resendConflict}),
  context: context,
);

extension InvitationExtension on GuestInvitation {
  String get invitedAtFrom {
    final invitationDate = createdAt.formattedDate;
    final invitorName = invitedBy.name ?? invitedBy.userId;
    return t.guests.invitation.invitedAtFrom(date: invitationDate, name: invitorName);
  }

  List<Action<GuestInvitation>> actions(BuildContext context) {
    final theme = Theme.of(context);
    return [
      // TODO does not work API side yet for revoked and expired invitations
      Action(
        label: t.guests.invitation.resend.title,
        icon: Icons.send,
        primary: true,
        action: (onSuccess) => _resendInvitation(context: context, invitation: this, onSuccess: onSuccess),
      ),
      if (status != GuestInvitationStatus.revoked)
        Action(
          label: t.guests.invitation.revoke.title,
          icon: Icons.block,
          color: theme.colorScheme.error,
          action: (onSuccess) => _revokeInvitation(context: context, invitation: this, onSuccess: onSuccess),
        ),
    ];
  }
}
