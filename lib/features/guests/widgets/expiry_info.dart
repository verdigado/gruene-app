import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/horizontal_divider.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestExpiryInfo extends StatelessWidget {
  final Guest guest;
  final bool withText;

  const GuestExpiryInfo({super.key, required this.guest, this.withText = false});

  @override
  Widget build(BuildContext context) {
    final expiresAt = guest.expiresAt;
    if (guest.status == GuestStatus.blocked) {
      return Text(t.guests.status.blocked);
    }

    if (expiresAt == null) {
      return Text(t.common.unknown);
    }

    if (guest.status == GuestStatus.expired) {
      return Text(expiresAt.formattedDate);
    }

    return _ExpiryRow(
      expiresAt: expiresAt,
      text: withText ? t.guests.validUntilDate(date: expiresAt.formattedDate) : null,
    );
  }
}

class GuestInvitationExpiryInfo extends StatelessWidget {
  final GuestInvitation invitation;
  final bool withText;

  const GuestInvitationExpiryInfo({super.key, required this.invitation, this.withText = false});

  @override
  Widget build(BuildContext context) {
    final expiresAt = invitation.expiresAt;
    return switch (invitation.status) {
      GuestInvitationStatus.revoked => Text(t.guests.invitation.status.revoked),
      GuestInvitationStatus.open => _ExpiryRow(
        expiresAt: expiresAt,
        text: withText ? t.guests.invitation.validUntilDate(date: expiresAt.formattedDate) : null,
      ),
      GuestInvitationStatus.expired ||
      GuestInvitationStatus.accepted ||
      GuestInvitationStatus.swaggerGeneratedUnknown => Text(expiresAt.formattedDate),
    };
  }
}

class _ExpiryRow extends StatelessWidget {
  final DateTime expiresAt;
  final String? text;

  const _ExpiryRow({required this.expiresAt, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text ?? expiresAt.formattedDate),
        Text(t.guests.daysLeft(days: expiresAt.daysUntil)),
      ].withDividers(HorizontalDivider()),
    );
  }
}
