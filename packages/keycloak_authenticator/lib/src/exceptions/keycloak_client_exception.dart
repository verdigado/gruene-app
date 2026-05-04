import 'package:dio/dio.dart';

enum KeycloakExceptionType {
  notRegistered,
  badRequest,
  networkError,
  serverError,
  unknown,
}

class KeycloakClientException implements Exception {
  String message;
  KeycloakExceptionType type;
  Object innerException;

  KeycloakClientException(
    this.message, {
    required this.type,
    required this.innerException,
  });
}

extension KeycloakClientExceptionExtension on DioException {
  KeycloakClientException keycloakClientException(String message) {
    if (type == DioExceptionType.badResponse) {
      final statusCode = response?.statusCode;
      final type = switch (statusCode) {
        null => KeycloakExceptionType.unknown,
        409 || 412 => KeycloakExceptionType.notRegistered,
        >= 500 => KeycloakExceptionType.serverError,
        _ => KeycloakExceptionType.badRequest,
      };
      return KeycloakClientException(message, type: type, innerException: this);
    }
    return KeycloakClientException(message, type: KeycloakExceptionType.networkError, innerException: this);
  }
}
