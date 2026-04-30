import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:keycloak_authenticator/src/storage/storage.dart';

class FlutterSecureStorageAdapter implements Storage {
  final FlutterSecureStorage _storage;

  FlutterSecureStorageAdapter(FlutterSecureStorage storage) : _storage = storage;

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String? value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<bool> containsKey({required String key}) {
    return _storage.containsKey(
      key: key,
    );
  }
}
