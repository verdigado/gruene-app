import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

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

/// The token is in the fragment, which browsers don't send to the server.
String? invitationToken(Uri uri) {
  final token = Uri.splitQueryString(uri.fragment)['token'];
  return token == null || token.isEmpty ? null : token;
}

final _handledInvitationTokens = <String>{};

/// Has to run before the first router is created.
Future<void> loadHandledInvitations() async {
  final stored = await GetIt.I<FlutterSecureStorage>().read(key: SecureStorageKeys.guestsHandledInvitations);
  if (stored != null) _handledInvitationTokens.addAll(List<String>.from(jsonDecode(stored) as List));
}

/// Keeps the router from opening the invitation again. This is stored, because Android restarts a killed app with the
/// link it was opened with, also when reopening it from the launcher, until its task is removed from the recent apps.
void markInvitationHandled(String? token) {
  if (token == null || !_handledInvitationTokens.add(token)) return;
  unawaited(
    GetIt.I<FlutterSecureStorage>().write(
      key: SecureStorageKeys.guestsHandledInvitations,
      value: jsonEncode(_handledInvitationTokens.toList()),
    ),
  );
}

bool isInvitationHandled(String? token) => _handledInvitationTokens.contains(token);

extension InvalidPasswordExtension on ApiException {
  bool get isInvalidPassword => message?.contains('invalidPassword') ?? false;
}

/// Returns the date as `yyyy-MM-dd`, or null if it isn't a plausible birth date.
String? parseBirthDate(String? value) {
  try {
    final date = DateFormat(dateFormat).parseStrict(value?.trim() ?? '');
    if (date.year < 1900 || date.isAfter(DateTime.now())) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  } on FormatException {
    return null;
  }
}

/// The realm's password policy, which Keycloak has the final say on.
class PasswordRules {
  final String password;
  final String repeat;
  final String email;

  static const maxLength = 256;

  const PasswordRules({required this.password, required this.repeat, required this.email});

  bool get longEnough => password.length >= 12;
  bool get notTooLong => password.length <= maxLength;
  bool get hasLetters =>
      password.contains(RegExp(r'\p{Ll}', unicode: true)) && password.contains(RegExp(r'\p{Lu}', unicode: true));
  bool get hasDigit => password.contains(RegExp(r'\p{Nd}', unicode: true));
  bool get differsFromEmail => password.isNotEmpty && password.toLowerCase() != email.toLowerCase();
  bool get match => password.isNotEmpty && password == repeat;
  bool get fulfilled => longEnough && notTooLong && hasLetters && hasDigit && differsFromEmail && match;
}
