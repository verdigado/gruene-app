import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

class MfaFactory {
  static AuthenticatorService create() {
    final secureStorage = GetIt.instance<FlutterSecureStorage>();
    return AuthenticatorService(storage: FlutterSecureStorageAdapter(secureStorage));
  }
}
