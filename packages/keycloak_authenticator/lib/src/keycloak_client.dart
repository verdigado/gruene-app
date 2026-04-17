import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:keycloak_authenticator/src/exceptions/keycloak_client_exception.dart';
import 'package:keycloak_authenticator/src/utils/crypto_utils.dart';
import 'package:pointycastle/export.dart';

import 'enums/enums.dart';
import 'dtos/challenge.dart';

class KeycloakClient {
  final Dio _dio;
  final PrivateKey _privateKey;
  final SignatureAlgorithm _signatureAlgorithm;
  final KeyAlgorithm _keyAlgorithm;

  KeycloakClient({
    required String baseUrl,
    required SignatureAlgorithm signatureAlgorithm,
    required KeyAlgorithm keyAlgorithm,
    required PrivateKey privateKey,
  })  : _signatureAlgorithm = signatureAlgorithm,
        _keyAlgorithm = keyAlgorithm,
        _privateKey = privateKey,
        _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(LogInterceptor(responseBody: true, error: true));
  }

  String _getSignatureAlgorithm() {
    return switch (_signatureAlgorithm) {
      SignatureAlgorithm.SHA256withRSA => 'SHA-256/RSA',
      SignatureAlgorithm.SHA512withRSA => 'SHA-512/RSA',
      SignatureAlgorithm.SHA512withECDSA => 'SHA-512/ECDSA',
    };
  }

  String _sign(String value) {
    var algorithmName = _getSignatureAlgorithm();
    Uint8List signature = switch (_keyAlgorithm) {
      KeyAlgorithm.RSA => CryptoUtils.rsaSign(
          _privateKey as RSAPrivateKey,
          Uint8List.fromList(value.codeUnits),
          algorithmName: algorithmName,
        ),
      KeyAlgorithm.EC => CryptoUtils.ecSign(
          _privateKey as ECPrivateKey,
          Uint8List.fromList(value.codeUnits),
          algorithmName: algorithmName,
        ),
    };
    return base64Encode(signature);
  }

  String buildSignatureHeader(
    String keyId,
    Map<String, String> keyValues,
  ) {
    var buffer = StringBuffer();
    var first = true;
    keyValues.forEach((key, value) {
      if (!first) {
        buffer.write(',');
      }
      buffer.writeAll([key, ':', value]);
      first = false;
    });
    var payload = buffer.toString();
    var signature = _sign(payload);
    return 'keyId:$keyId,$payload,signature:$signature';
  }

  Future<void> setup({
    required String clientId,
    required String tabId,
    required String key,
    required String deviceId,
    required DeviceOs deviceOs,
    String? devicePushId,
    required String publicKey,
    required KeyAlgorithm keyAlgorithm,
    required SignatureAlgorithm signatureAlgorithm,
  }) async {
    try {
      await _setupRequest(
          clientId, tabId, deviceId, deviceOs, devicePushId, keyAlgorithm, signatureAlgorithm, publicKey, key);
    } on DioException catch (err) {
      if (err.type == DioExceptionType.badResponse) {
        throw KeycloakClientException('', dioException: err);
      }
      throw KeycloakClientException('', dioException: err);
    }
  }

  Future<void> _setupRequest(
    String clientId,
    String tabId,
    String deviceId,
    DeviceOs deviceOs,
    String? devicePushId,
    KeyAlgorithm keyAlgorithm,
    SignatureAlgorithm signatureAlgorithm,
    String publicKey,
    String key,
  ) async {
    await _dio.get(
      '/login-actions/action-token',
      queryParameters: {
        'client_id': clientId,
        'tab_id': tabId,
        'device_id': deviceId,
        'device_os': deviceOs.name.toString(),
        'device_push_id': devicePushId,
        'key_algorithm': keyAlgorithm.name.toString(),
        'signature_algorithm': signatureAlgorithm.name.toString(),
        'public_key': publicKey,
        'key': key,
      },
    );
  }

  Future<List<Challenge>> getChallenges(
    String deviceId,
  ) async {
    try {
      return await _getChallengesRequest(deviceId);
    } on DioException catch (err) {
      if (err.type == DioExceptionType.badResponse) {
        var type = switch (err.response?.statusCode) {
          400 => KeycloakExceptionType.badRequest,
          409 => KeycloakExceptionType.notRegistered,
          int() => KeycloakExceptionType.badRequest,
          null => KeycloakExceptionType.badRequest,
        };
        throw KeycloakClientException('message', dioException: err, type: type);
      }
      rethrow;
    }
  }

  Future<List<Challenge>> _getChallengesRequest(String deviceId) async {
    var signatureHeader = buildSignatureHeader(
      deviceId,
      {
        'created': (DateTime.now().millisecondsSinceEpoch - 1000).toString(),
        // 'request-target': 'get_/realms/$realm/challenge-resource/$deviceId',
      },
    );
    var res = await _dio.get(
      '/challenges',
      queryParameters: {
        'device_id': deviceId,
      },
      options: Options(
        headers: {
          'signature': signatureHeader,
        },
      ),
    );
    return (res.data as List<dynamic>).map((e) => Challenge.fromJson(e)).toList();
  }

  Future<void> replyChallenge({
    required String deviceId,
    required String clientId,
    required String tabId,
    required String key,
    required String value,
    required bool granted,
    required int timestamp,
  }) async {
    try {
      await _challengeReplyRequest(deviceId, timestamp, value, granted, clientId, tabId, key);
    } on DioException catch (e) {
      throw KeycloakClientException('request failed', dioException: e);
    }
  }

  Future<void> _challengeReplyRequest(
      String deviceId, int timestamp, String value, bool granted, String clientId, String tabId, String key) async {
    var signatureHeader = buildSignatureHeader(
      deviceId,
      {
        // 'created': DateTime.now().millisecondsSinceEpoch.toString(),
        'created': timestamp.toString(),
        'secret': value,
        'granted': granted ? 'true' : 'false',
      },
    );
    await _dio.get(
      '/login-actions/action-token',
      queryParameters: {
        'client_id': clientId,
        'tab_id': tabId,
        'key': key,
        'granted': granted,
      },
      options: Options(
        headers: {
          'signature': signatureHeader,
        },
      ),
    );
  }

  Future<void> updateDevicePushId({
    required String deviceId,
    required String? devicePushId,
  }) async {
    try {
      await _updateDevicePushIdRequest(deviceId, devicePushId);
    } on DioException catch (e) {
      throw KeycloakClientException('Failed to update push notification token', dioException: e);
    }
  }

  Future<void> _updateDevicePushIdRequest(String deviceId, String? devicePushId) async {
    final signatureHeader = buildSignatureHeader(
      deviceId,
      {
        'created': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    await _dio.put(
      '/$deviceId/credentials',
      data: {
        'devicePushId': devicePushId,
      },
      options: Options(
        headers: {
          'signature': signatureHeader,
        },
      ),
    );
  }
}
