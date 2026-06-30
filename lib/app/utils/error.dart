import 'package:gruene_app/i18n/translations.g.dart';
import 'package:http/http.dart';
import 'package:keycloak_authenticator/api.dart';

String getErrorMessage(Object error, {String? defaultMessage}) {
  if (error is KeycloakClientException) {
    return switch (error.type) {
      KeycloakExceptionType.networkError => t.error.offlineError,
      _ => defaultMessage ?? t.error.unknownError,
    };
  }

  if (error is ClientException || error.toString().contains('Failed host lookup')) {
    return t.error.offlineError;
  }
  return defaultMessage ?? t.error.unknownError;
}
