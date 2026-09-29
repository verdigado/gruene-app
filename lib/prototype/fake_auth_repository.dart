import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// Stands in for [AuthRepository] in prototype mode.
///
/// Skips Keycloak entirely: "logging in" just writes a well-formed fake token
/// for the currently selected persona, so every downstream consumer of the
/// access token keeps working unchanged.
class FakeAuthRepository extends AuthRepository {
  final _storage = GetIt.I<FlutterSecureStorage>();

  @override
  Future<bool> login() async {
    await _writeTokens();
    logger.d('Prototype login as ${prototypePersona.value.name}');
    return true;
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: SecureStorageKeys.accessToken);
    await _storage.delete(key: SecureStorageKeys.idToken);
    await _storage.delete(key: SecureStorageKeys.refreshToken);
    logger.d('Prototype logout');
  }

  @override
  Future<bool> isTokenValid() async {
    // Prototype sessions never expire; always boot straight into the app.
    await _writeTokens();
    return true;
  }

  /// Upstream renamed this from `refreshToken` and it now returns the new
  /// access token rather than a bool.
  @override
  Future<String?> refreshAccessToken() async {
    await _writeTokens();
    return prototypePersona.value.fakeAccessToken;
  }

  /// Re-issues the token for whichever persona is currently selected.
  /// Called by the dev drawer when the persona changes.
  Future<void> switchPersona(PrototypePersona persona) async {
    prototypePersona.value = persona;
    await _writeTokens();
  }

  Future<void> _writeTokens() async {
    final token = prototypePersona.value.fakeAccessToken;
    await _storage.write(key: SecureStorageKeys.accessToken, value: token);
    await _storage.write(key: SecureStorageKeys.idToken, value: token);
    await _storage.write(key: SecureStorageKeys.refreshToken, value: 'prototype-refresh-token');
  }
}

/// Wraps the app so it rebuilds whenever the simulated persona changes.
class PrototypeScope extends StatelessWidget {
  const PrototypeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PrototypePersona>(
      valueListenable: prototypePersona,
      builder: (context, persona, _) => KeyedSubtree(key: ValueKey(persona.id), child: child),
    );
  }
}
