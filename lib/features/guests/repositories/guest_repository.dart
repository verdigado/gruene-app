import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';

/// Android restarts a killed app with the link it was opened with until its task is removed from the recent apps.
final _handledInvitationTokens = <String>{};

Future<void> loadHandledInvitations() async {
  final stored = await GetIt.I<FlutterSecureStorage>().read(key: SecureStorageKeys.guestsHandledInvitations);
  if (stored != null) _handledInvitationTokens.addAll(List<String>.from(jsonDecode(stored) as List));
}

void markInvitationHandled(String? token) {
  if (token == null || !_handledInvitationTokens.add(token)) return;
  GetIt.I<FlutterSecureStorage>().write(
    key: SecureStorageKeys.guestsHandledInvitations,
    value: jsonEncode(_handledInvitationTokens.toList()),
  );
}

bool isInvitationHandled(String? token) => _handledInvitationTokens.contains(token);
