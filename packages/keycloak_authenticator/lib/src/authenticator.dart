library;

import 'package:keycloak_authenticator/src/dtos/challenge.dart';

abstract class Authenticator {
  String getId();
  String? getLabel();
  Future<Challenge?> fetchChallenge();
  Future<void> reply({required Challenge challenge, required bool granted});
  Future<void> updateDevicePushId({required String? devicePushId});
}
