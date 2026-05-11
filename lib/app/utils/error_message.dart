import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';
import 'package:gruene_app/i18n/translations.g.dart';

String getErrorMessage(Object error, {String? defaultMessage}) {
  if (error is KeycloakClientException) {
    return switch (error.type) {
      KeycloakExceptionType.networkError => t.error.offlineError,
      _ => defaultMessage ?? t.error.unknownError,
    };
  }

  if (error.toString().contains('Failed host lookup')) {
    return t.error.offlineError;
  }
  return defaultMessage ?? t.error.unknownError;
}
