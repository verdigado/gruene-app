import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/services/ip_service.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:keycloak_authenticator/api.dart';

class AuthRepository {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final _secureStorage = GetIt.instance<FlutterSecureStorage>();
  final AuthenticatorService _authenticatorService = GetIt.I<AuthenticatorService>();
  final IpService _ipService = GetIt.I<IpService>();

  Future<bool> login() async {
    final authenticator = await _authenticatorService.getFirst();
    final pollingTimer = authenticator != null ? _pollForChallenge(authenticator) : null;
    try {
      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          Config.oidcClientId,
          Config.oidcCallbackPath,
          allowInsecureConnections: Config.isDevelopment,
          issuer: Config.oidcIssuer,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      await _secureStorage.write(key: SecureStorageKeys.accessToken, value: result.accessToken);
      await _secureStorage.write(key: SecureStorageKeys.idToken, value: result.idToken);
      await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: result.refreshToken);

      logger.d('Login successful');

      return true;
    } on FlutterAppAuthUserCancelledException catch (e) {
      logger.d('Login cancelled: $e');
    } catch (e) {
      logger.w('SLogin failed: $e');
    } finally {
      stopPolling(pollingTimer);
    }
    return false;
  }

  /// Performs a back-channel logout to revoke the offline session.
  /// The flutter_appauth library uses a front-channel logout by default.
  Future<void> _endSession(String refreshToken) async {
    final dio = Dio();

    final Response<void> response = await dio.post(
      '${Config.oidcIssuer}/protocol/openid-connect/logout',
      data: {
        'client_id': Config.oidcClientId,
        'refresh_token': refreshToken,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      throw Exception('Back-channel logout failed with status: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    if (refreshToken != null) {
      try {
        await _endSession(refreshToken);
        logger.d('Logout successful');
      } catch (e) {
        logger.w('Logout failed: $e');
      }
    }

    await _deleteTokens();
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.accessToken);
  }

  Future<bool> isTokenValid() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      logger.d('No access token found');
      return false;
    }

    final isExpired = JwtDecoder.isExpired(accessToken);
    logger.d('Access token ${isExpired ? 'expired' : 'valid'}');
    return !isExpired;
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    if (refreshToken == null) {
      logger.d('No refresh token found');
      return false;
    }

    try {
      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          Config.oidcClientId,
          Config.oidcCallbackPath,
          allowInsecureConnections: Config.isDevelopment,
          refreshToken: refreshToken,
          issuer: Config.oidcIssuer,
        ),
      );

      await _secureStorage.write(key: SecureStorageKeys.accessToken, value: result.accessToken);
      await _secureStorage.write(key: SecureStorageKeys.idToken, value: result.idToken);
      await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: result.refreshToken);
      logger.d('Token refresh successful');
      return true;
    } catch (e) {
      logger.w('Token refresh failed: $e');
    }
    return false;
  }

  Future<void> _deleteTokens() async {
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.idToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
    logger.d('Auth tokens deleted successfully');
  }

  Timer _pollForChallenge(Authenticator authenticator) {
    final startTime = DateTime.now();
    final timeout = Duration(seconds: 120);

    return Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        if (DateTime.now().difference(startTime) > timeout) {
          stopPolling(timer);
          return;
        }

        final challenge = await authenticator.fetchChallenge();
        if (challenge != null && await _ipService.isOwnIp(challenge.ipAddress)) {
          stopPolling(timer);
          await authenticator.reply(challenge: challenge, granted: true);
          logger.d('Challenge approved successfully');
        }
      } catch (e) {
        logger.w('Challenge polling failed: $e');
      }
    });
  }

  void stopPolling(Timer? pollingTimer) {
    if (pollingTimer != null && pollingTimer.isActive) {
      pollingTimer.cancel();
    }
  }
}
