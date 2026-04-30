import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Challenge {
  /// User who is requesting authentication
  final String userName;

  /// User first name
  final String userFirstName;

  /// User last name
  final String userLastName;

  /// URL containing JWT to send challenge to
  final String targetUrl;

  /// random string to be signed
  final String secret;

  /// Unix timestamp in milliseconds the user requested authentication (login)
  final int updatedTimestamp;

  /// IP address of the requesting device
  final String ipAddress;

  /// The requesting device, e.g. iPhone
  final String device;

  /// Browser of the requesting device
  final String browser;

  /// OS of the requesting device
  final String os;

  /// OS version of the requesting device
  final String osVersion;

  /// Expiration of the action token by Keycloak in seconds
  final int? expiresIn;

  /// Name of the client
  final String clientName;

  /// A random value that is passed to the authorization endpoint
  final String? loginId;

  Challenge({
    required this.userName,
    required this.userFirstName,
    required this.userLastName,
    required this.targetUrl,
    required this.secret,
    required this.updatedTimestamp,
    required this.ipAddress,
    required this.device,
    required this.browser,
    required this.os,
    required this.osVersion,
    required this.expiresIn,
    required this.clientName,
    this.loginId,
  });

  static int? _getExpiresInFromUrl(String? targetUrl) {
    if (targetUrl == null) {
      return null;
    }
    final url = Uri.tryParse(targetUrl);
    if (url == null) {
      return null;
    }
    final key = url.queryParameters['key'];
    if (key == null) {
      return null;
    }
    final jwt = JWT.tryDecode(key);
    if (jwt == null) {
      return null;
    }
    final expiresAt = jwt.payload?['exp'] as int?;
    if (expiresAt == null) {
      return null;
    }
    return max(0, expiresAt - DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      userName: json['userName'] as String,
      userFirstName: json['userFirstName'] as String,
      userLastName: json['userLastName'] as String,
      targetUrl: json['targetUrl'] as String,
      secret: json['codeChallenge'] as String,
      updatedTimestamp: json['updatedTimestamp'] as int,
      ipAddress: json['ipAddress'] as String,
      device: json['device'] as String,
      browser: json['browser'] as String,
      os: json['os'] as String,
      osVersion: json['osVersion'] as String,
      expiresIn: _getExpiresInFromUrl(json['targetUrl'] as String?),
      clientName: json['clientName'] as String,
      loginId: json['loginId'] as String?,
    );
  }
}
