import 'dart:convert';

import 'package:keycloak_authenticator/src/authenticator.dart';
import 'package:keycloak_authenticator/src/authenticator_repository.dart';
import 'package:keycloak_authenticator/src/dtos/activation_token_dto.dart';
import 'package:keycloak_authenticator/src/dtos/authenticator_entry.dart';
import 'package:keycloak_authenticator/src/enums/enums.dart';
import 'package:keycloak_authenticator/src/keycloak_authenticator.dart';
import 'package:keycloak_authenticator/src/keycloak_client.dart';
import 'package:keycloak_authenticator/src/storage/storage.dart';
import 'package:keycloak_authenticator/src/utils/crypto_utils.dart';
import 'package:keycloak_authenticator/src/utils/device_utils.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';

class AuthenticatorService {
  final AuthenticatorRepository _repository;
  final uuid = const Uuid();
  AuthenticatorService({required Storage storage}) : _repository = AuthenticatorRepository(storage: storage);

  Future<Authenticator> create(
    String aktivationTokenUrl, {
    SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.SHA512withECDSA,
    String? label,
  }) async {
    var token = ActivationTokenDto.fromUrl(aktivationTokenUrl);

    // TODO: check if combination of keycloak instance an realm is already registered

    var keyAlgorithm = _getKeyAlgorithmForSignatureAlgorithm(signatureAlgorithm);

    AsymmetricKeyPair keyPair;
    String encodedPublicKey;
    switch (keyAlgorithm) {
      case KeyAlgorithm.RSA:
        keyPair = await CryptoUtils.generateRsaKeyPairAsync(bitLength: 4096);
        encodedPublicKey = base64Encode(CryptoUtils.encodeRsaPublicKeyToPkcs8(keyPair.publicKey as RSAPublicKey));
        break;
      case KeyAlgorithm.EC:
        keyPair = await CryptoUtils.generateEcKeyPairAsync();
        encodedPublicKey = base64Encode(CryptoUtils.encodeEcPublicKeyToPkcs8(keyPair.publicKey as ECPublicKey));
        break;
    }

    var devicePushId = await DeviceUtils.getDevicePushId();
    DeviceOs deviceOs = DeviceUtils.getDeviceOs();
    var authenticatorId = uuid.v4();

    var client = KeycloakClient(
      baseUrl: token.baseUrl,
      signatureAlgorithm: signatureAlgorithm,
      keyAlgorithm: keyAlgorithm,
      privateKey: keyPair.privateKey,
    );

    await client.setup(
      clientId: token.clientId,
      tabId: token.tabId,
      deviceId: authenticatorId,
      deviceOs: deviceOs,
      key: token.key,
      publicKey: encodedPublicKey,
      keyAlgorithm: keyAlgorithm,
      signatureAlgorithm: signatureAlgorithm,
      devicePushId: devicePushId,
    );

    var authenticator = KeycloakAuthenticator.fromParams(
      id: authenticatorId,
      label: label,
      baseUrl: token.baseUrl,
      realm: token.realm,
      signatureAlgorithm: signatureAlgorithm,
      keyAlgorithm: keyAlgorithm,
      privateKey: keyPair.privateKey,
    );

    await _repository.add(authenticator);

    return authenticator;
  }

  Future<Authenticator?> getById(String authenticatorId) {
    return _repository.getById(authenticatorId);
  }

  Future<Authenticator?> getFirst() async {
    var entries = await _repository.getEntries();
    var firstEntry = entries.firstOrNull;
    return firstEntry != null ? await _repository.getById(firstEntry.id) : null;
  }

  Future<List<AuthenticatorEntry>> getEntries() {
    return _repository.getEntries();
  }

  Future<void> delete(Authenticator authenticator) {
    return _repository.delete(authenticator);
  }

  KeyAlgorithm _getKeyAlgorithmForSignatureAlgorithm(SignatureAlgorithm signatureAlgorithm) {
    switch (signatureAlgorithm) {
      case SignatureAlgorithm.SHA256withRSA:
      case SignatureAlgorithm.SHA512withRSA:
        return KeyAlgorithm.RSA;
      case SignatureAlgorithm.SHA512withECDSA:
        return KeyAlgorithm.EC;
    }
  }
}
