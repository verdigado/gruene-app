import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/extensions.dart';
import 'package:intl/intl.dart';

/// Android restarts a killed app with the link it was opened with until its task is removed from the recent apps.
final _handledInvitationTokens = <String>{};

Future<void> loadHandledInvitations() async {
  final stored = await GetIt.I<FlutterSecureStorage>().read(key: SecureStorageKeys.guestsHandledInvitations);
  if (stored != null) _handledInvitationTokens.addAll(List<String>.from(jsonDecode(stored) as List));
}

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

String? invitationToken(Uri uri) {
  final token = Uri.splitQueryString(uri.fragment)['token'];
  return token.isNullOrEmpty() ? null : token;
}

String? parseBirthDate(String? value) {
  try {
    final date = DateFormat(dateFormat).parseStrict(value?.trim() ?? '');
    if (date.year < 1900 || date.isAfter(DateTime.now())) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  } on FormatException {
    return null;
  }
}

class KeycloakPasswordPolicy {
  final String password;
  final String repeat;
  final String email;

  static const minLength = 12;
  static const maxLength = 256;

  const KeycloakPasswordPolicy({required this.password, required this.repeat, required this.email});

  bool get longEnough => password.length >= minLength;
  bool get notTooLong => password.length <= maxLength;
  bool get hasLetters =>
      password.contains(RegExp(r'\p{Ll}', unicode: true)) && password.contains(RegExp(r'\p{Lu}', unicode: true));
  bool get hasDigit => password.contains(RegExp(r'\p{Nd}', unicode: true));
  bool get differsFromEmail => password.isNotEmpty && password.toLowerCase() != email.toLowerCase();
  bool get matches => password.isNotEmpty && password == repeat;
  bool get fulfilled => longEnough && notTooLong && hasLetters && hasDigit && differsFromEmail && matches;
}
