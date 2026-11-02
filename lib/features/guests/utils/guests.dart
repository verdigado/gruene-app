import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension GuestStatusExtension on GuestStatus {
  String get label => switch (this) {
    GuestStatus.active => t.guests.status.active,
    GuestStatus.blocked => t.guests.status.blocked,
    GuestStatus.expired => t.guests.status.expired,
    GuestStatus.swaggerGeneratedUnknown => t.common.unknown,
  };

  Color color(ThemeData theme) => switch (this) {
    GuestStatus.active => theme.colorScheme.secondary,
    GuestStatus.blocked => theme.colorScheme.error,
    GuestStatus.expired || GuestStatus.swaggerGeneratedUnknown => ThemeColors.text,
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

  Color color(ThemeData theme) => switch (this) {
    GuestHistoryType.accepted || GuestHistoryType.renewed || GuestHistoryType.unblocked => theme.colorScheme.secondary,
    GuestHistoryType.invited => ThemeColors.warning,
    GuestHistoryType.blocked => theme.colorScheme.error,
    GuestHistoryType.expired || GuestHistoryType.swaggerGeneratedUnknown => ThemeColors.text,
  };

  IconData get icon => switch (this) {
    GuestHistoryType.invited => Icons.send,
    GuestHistoryType.accepted => Icons.check,
    GuestHistoryType.renewed => Icons.more_time,
    GuestHistoryType.expired => Icons.hourglass_disabled,
    GuestHistoryType.blocked => Icons.block,
    GuestHistoryType.unblocked => Icons.lock_open,
    GuestHistoryType.swaggerGeneratedUnknown => Icons.question_mark,
  };
}

extension GuestExtension on Guest {
  String get fullName => '$firstName $lastName';

  bool matches(String query) {
    final normalizedQuery = query.normalized;
    return normalizedQuery.isEmpty ||
        fullName.normalized.contains(normalizedQuery) ||
        (email?.normalized.contains(normalizedQuery) ?? false);
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
    expiresAt: expiresAt,
  );
}
