import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Challenge {
  /// User who is requesting authentication
  final String userName;

  /// User frist name
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
    var url = Uri.tryParse(targetUrl);
    if (url == null) {
      return null;
    }
    var key = url.queryParameters['key'];
    if (key == null) {
      return null;
    }
    var jwt = JWT.tryDecode(key);
    if (jwt == null) {
      return null;
    }
    int? expiresAt = jwt.payload?['exp'];
    if (expiresAt == null) {
      return null;
    }
    return max(0, expiresAt - DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
        userName: json['userName'],
        userFirstName: json['userFirstName'],
        userLastName: json['userLastName'],
        targetUrl: json['targetUrl'],
        secret: json['codeChallenge'],
        updatedTimestamp: json['updatedTimestamp'],
        ipAddress: json['ipAddress'],
        device: json['device'],
        browser: json['browser'],
        os: json['os'],
        osVersion: json['osVersion'],
        expiresIn: _getExpiresInFromUrl(json['targetUrl']),
        clientName: json['clientName'],
        loginId: json['loginId']);
  }
}
