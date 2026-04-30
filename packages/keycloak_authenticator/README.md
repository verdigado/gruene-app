A flutter package implementing Keycloak multifactor authentication (mfa) with https://github.com/netzbegruenung/keycloak-mfa-plugins/tree/main/app-authenticator.

## Features

This package provides a flutter implementation for keycloak multifactor authentication.
It supports push notifications for new challenges (e.g. with [firebase](https://pub.dev/packages/firebase_messaging))
and provides a [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) implementation to persist the setup.
Supports registering multiple authenticators.

## Getting started

Add the package to your pubspec.yaml:

``` shell
fvm flutter pub add flutter_keycloak_authenticator
```

## Usage

### Setup

``` dart
// Use the provided adapter for https://pub.dev/packages/flutter_secure_storage or a custom storage implementation
final storage = FlutterSecureStorageAdapter(FlutterSecureStorage());
final AuthenticatorService service = AuthenticatorService(storage: storage);

// Setup with https://pub.dev/packages/firebase_messaging to receive push notifications for new challenges
// Pass null as `devicePushId` to skip the push notification setup
final devicePushId = await FirebaseMessaging.instance.getToken();

// Get the already registered authenticator or create a new one
final authenticator = await service.getFirst() ?? await service.create(activationToken, devicePushId: devicePushId);

// Listen to firebase token refreshes
FirebaseMessaging.instance.onTokenRefresh.listen(
  (devicePushId) async => await authenticator.updateDevicePushId(devicePushId: devicePushId),
);
```

### Fetch a challenge

``` dart
final challenge = await authenticator.fetchChallenge();
```

### Reply to a challenge

``` dart
await authenticator.reply(challenge: challenge, granted: true);
```

### Update the devicePushId

``` dart
await authenticator?.updateDevicePushId(devicePushId: devicePushId);
```

### Unregister an authenticator

``` dart
await service.delete(authenticator);
```

## Additional information

https://github.com/netzbegruenung/keycloak-mfa-plugins/tree/main/app-authenticator
