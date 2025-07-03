import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/services/interceptors/auth_interceptor.dart';
import 'package:gruene_app/app/utils/logger.dart';

const retryCountHeader = 'Retry-Count';

class AccessTokenAuthenticator implements Authenticator {
  final AuthRepository _authRepository = AuthRepository();
  Completer<String?>? _completer;

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

      try {
        final newAccessToken = await _refreshToken();
        final updatedRequest = applyHeaders(request, {
          HttpHeaders.authorizationHeader: '$bearerPrefix ${newAccessToken!}',
          retryCountHeader: '1',
        });

        return updatedRequest;
      } catch (e) {
        logger.w('Failed to refresh access token: $e');
        return null;
      }
    }

    return null;
  }

  Future<String?> _refreshToken() {
    var completer = _completer;
    if (completer != null && !completer.isCompleted) {
      logger.d('Access token refresh is already in progress');
      return completer.future;
    }

    completer = Completer<String?>();
    _completer = completer;

    _authRepository
        .refreshToken()
        .then((success) {
          if (success) {
            completer?.complete(_authRepository.getAccessToken());
          } else {
            completer?.completeError('Failed to refresh token', StackTrace.current);
          }
        })
        .onError((error, stackTrace) {
          completer?.completeError(error ?? 'Refresh token error', stackTrace);
        });

    return completer.future;
  }

  @override
  AuthenticationCallback? get onAuthenticationFailed => null;

  @override
  AuthenticationCallback? get onAuthenticationSuccessful => null;
}
