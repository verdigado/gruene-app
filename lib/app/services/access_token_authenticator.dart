import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/services/interceptors/auth_interceptor.dart';
import 'package:gruene_app/app/utils/logger.dart';

const retryCountHeader = 'Retry-Count';

class AccessTokenAuthenticator implements Authenticator {
  final AuthRepository _authRepository = AuthRepository();

  AccessTokenAuthenticator();

  @override
  FutureOr<Request?> authenticate(Request request, Response<dynamic> response, [Request? originalRequest]) async {
    logger.d('${request.method} ${request.url}');
    if (request.body != null) {
      logger.d('Body: ${request.body}');
    }
    logger.d('Response: ${response.statusCode}');

    if (response.statusCode == HttpStatus.unauthorized) {
      if (request.headers[retryCountHeader] != null) {
        logger.d('Unable to refresh token, retry count exceeded');
        return null;
      }

      final newAccessToken = await _authRepository.refreshAccessToken();
      if (newAccessToken == null) {
        logger.w('Failed to refresh access token');
        return null;
      }

      return applyHeaders(request, {
        HttpHeaders.authorizationHeader: '$bearerPrefix $newAccessToken',
        retryCountHeader: '1',
      });
    }

    return null;
  }

  @override
  AuthenticationCallback? get onAuthenticationFailed => null;

  @override
  AuthenticationCallback? get onAuthenticationSuccessful => null;
}
