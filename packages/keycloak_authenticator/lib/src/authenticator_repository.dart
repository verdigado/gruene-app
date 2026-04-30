import 'dart:convert';

import 'package:keycloak_authenticator/src/authenticator.dart';
import 'package:keycloak_authenticator/src/dtos/authenticator_entry.dart';
import 'package:keycloak_authenticator/src/keycloak_authenticator.dart';
import 'package:keycloak_authenticator/src/storage/storage.dart';
import 'package:uuid/uuid.dart';

class AuthenticatorRepository {
  final Storage _storage;
  final uuid = const Uuid();

  AuthenticatorRepository({
    required Storage storage,
  }) : _storage = storage;

  String _getAuthenticatorStorageKey(String authenticatorId) {
    return 'authr:$authenticatorId';
  }

  Future<Authenticator> add(KeycloakAuthenticator authenticator) async {
    await _storage.write(
      key: _getAuthenticatorStorageKey(authenticator.getId()),
      value: jsonEncode(authenticator.toJson()),
    );

    await _addToEntries(authenticator);

    return authenticator;
  }

  Future<Authenticator?> getById(String authenticatorId) async {
    final serialized = await _storage.read(key: _getAuthenticatorStorageKey(authenticatorId));
    if (serialized == null) {
      return null;
    }
    return KeycloakAuthenticator.fromJson(jsonDecode(serialized) as Map<String, dynamic>);
  }

  Future<void> delete(Authenticator authenticator) async {
    _storage.delete(key: _getAuthenticatorStorageKey(authenticator.getId()));
    await _deleteFromEntries(authenticator);
  }

  Future<List<AuthenticatorEntry>> getEntries() async {
    List<AuthenticatorEntry> entries = [];
    final serialized = await _storage.read(key: 'entries');
    if (serialized != null) {
      final jsonList = jsonDecode(serialized) as List<dynamic>;
      entries = jsonList.map((json) => AuthenticatorEntry.fromJson(json as Map<String, dynamic>)).toList();
    }
    return entries;
  }

  Future<void> _saveEntries(List<AuthenticatorEntry> entries) async {
    await _storage.write(key: 'entries', value: jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<List<AuthenticatorEntry>> _addToEntries(Authenticator authenticator) async {
    final entries = await getEntries();
    entries.add(
      AuthenticatorEntry(
        id: authenticator.getId(),
        label: authenticator.getLabel(),
      ),
    );
    await _saveEntries(entries);
    return entries;
  }

  Future<List<AuthenticatorEntry>> _deleteFromEntries(Authenticator authenticator) async {
    final list = await getEntries();
    list.removeWhere((element) => element.id == authenticator.getId());
    await _saveEntries(list);
    return list;
  }
}
