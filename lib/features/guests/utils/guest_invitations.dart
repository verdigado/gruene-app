import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
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

  Color color(ThemeData theme) => switch (this) {
    GuestInvitationStatus.open => ThemeColors.warning,
    GuestInvitationStatus.revoked => theme.colorScheme.error,
    GuestInvitationStatus.accepted => theme.colorScheme.secondary,
    GuestInvitationStatus.expired || GuestInvitationStatus.swaggerGeneratedUnknown => ThemeColors.text,
  };
}

extension InvitationExtension on GuestInvitation {
  String get invitedAtFrom {
    final invitationDate = createdAt.formattedDate;
    final invitorName = invitedBy.name ?? invitedBy.userId;
    return t.guests.invitation.invitedAtFrom(date: invitationDate, name: invitorName);
  }
}
