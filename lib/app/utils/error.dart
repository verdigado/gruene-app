import 'dart:io';

import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:http/http.dart';

String getErrorMessage(Object error, {Map<int, String> byStatusCode = const {}}) {
  if (error is KeycloakClientException) {
    return switch (error.type) {
      KeycloakExceptionType.networkError => t.error.offline,
      _ => t.error.unknown,
    };
  }

  if (error is ApiException) {
    return byStatusCode[error.statusCode] ??
        switch (error.statusCode) {
          HttpStatus.unauthorized => t.error.sessionExpired,
          HttpStatus.forbidden => t.error.forbidden,
          HttpStatus.notFound => t.error.notFound,
          >= HttpStatus.internalServerError => t.error.serverUnavailable,
          _ => t.error.unknown,
        };
  }

  if (error is ClientException || error.toString().contains('Failed host lookup')) {
    return t.error.offline;
  }
  return t.error.unknown;
}
