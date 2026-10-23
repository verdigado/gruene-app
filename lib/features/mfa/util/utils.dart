import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';

extension ChallengeExtension on Challenge {
  DateTime get loginDateTime => DateTime.fromMillisecondsSinceEpoch(updatedTimestamp);
}
