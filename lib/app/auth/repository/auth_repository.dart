import 'dart:async';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/services/ip_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:keycloak_authenticator/api.dart';
import 'package:logger/logger.dart';

class AuthRepository {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final _secureStorage = GetIt.instance<FlutterSecureStorage>();
  final Logger _logger = Logger();
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
      return true;
    } on FlutterAppAuthUserCancelledException catch (e) {
      _logger.w('Login was cancelled: $e');
    } catch (e) {
      _logger.w('Login was not successful: $e');
    } finally {
      stopPolling(pollingTimer);
    }
    return false;
  }

  Future<void> logout() async {
    final idToken = await _secureStorage.read(key: SecureStorageKeys.idToken);

    await _appAuth.endSession(
      EndSessionRequest(
        idTokenHint: idToken,
        postLogoutRedirectUrl: Config.oidcCallbackPath,
        discoveryUrl: '${Config.oidcIssuer}/.well-known/openid-configuration',
        allowInsecureConnections: Config.isDevelopment,
      ),
    );

    await _deleteTokens();
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.accessToken);
  }

  Future<bool> isTokenValid() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    return !JwtDecoder.isExpired(accessToken);
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    if (refreshToken == null) return false;

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
      return true;
    } catch (e) {
      _logger.w('Token refresh was not successful: $e');
    }
    return false;
  }

  Future<void> _deleteTokens() async {
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.idToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
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
          await authenticator.reply(
            challenge: challenge,
            granted: true,
          );
        }
      } catch (e) {
        _logger.w('Error during challenge polling: $e');
      }
    });
  }

  void stopPolling(Timer? pollingTimer) {
    if (pollingTimer != null && pollingTimer.isActive) {
      pollingTimer.cancel();
    }
  }
}
