import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/features/campaigns/location/dialogs.dart';
import 'package:gruene_app/features/campaigns/location/location_ffi.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:logger/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

enum LocationStatus {
  /// This is the initial state on both Android and iOS, but on Android the
  /// user can still choose to deny permissions, meaning the App can still
  /// request for permission another time.
  denied,

  /// Permission to access the device's location is permenantly denied. When
  /// requestiong permissions the permission dialog will not been shown until
  /// the user updates the permission in the App settings.
  deniedForever,

  /// Permission to access the device's location is allowed only while
  /// the App is in use.
  whileInUse,

  /// Permission to access the device's location is allowed even when the
  /// App is running in the background.
  always,

  /// Requesting the location is not supported by this device. On Android
  /// the reason for this could be that the location service is not
  /// enabled.
  notSupported,
}

extension GeolocatorExtension on LocationPermission {
  LocationStatus toLocationStatus() {
    switch (this) {
      case LocationPermission.denied:
        return LocationStatus.denied;
      case LocationPermission.deniedForever:
        return LocationStatus.deniedForever;
      case LocationPermission.whileInUse:
        return LocationStatus.whileInUse;
      case LocationPermission.always:
        return LocationStatus.always;
      case LocationPermission.unableToDetermine:
        return LocationStatus.notSupported;
    }
  }
}

extension GrantedExtension on LocationStatus {
  bool isPermissionGranted() {
    return this == LocationStatus.always || this == LocationStatus.whileInUse;
  }
}

class RequestedPosition {
  Position? position;
  LocationStatus? locationStatus;

  RequestedPosition(this.position, this.locationStatus);

  RequestedPosition.unknown() : position = null, locationStatus = null;

  bool isAvailable() {
    return position != null;
  }

  LatLng? toLatLng() {
    // final currentPosition = position;
    // return currentPosition != null ? LatLng(currentPosition.latitude, currentPosition.longitude) : null;
    // return LatLng(52.1411211, 10.348218);
    return null;
  }
}

/// Determine the current position of the device.
Future<RequestedPosition> determinePosition(
  BuildContext context, {
  bool requestIfNotGranted = false,
  bool preferLastKnownPosition = false,
}) async {
  final Logger logger = Logger();

  final permission = await checkAndRequestLocationPermission(context, requestIfNotGranted: requestIfNotGranted);
  if (!permission.isPermissionGranted()) {
    return RequestedPosition(null, permission);
  }

  var position = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: Config.androidFloss);
  if (preferLastKnownPosition && position != null) {
    return RequestedPosition(position, permission);
  }
  try {
    try {
      final settings = getAndroidSettings();
      position = await Geolocator.getCurrentPosition(locationSettings: settings);
    } on LocationServiceDisabledException {
      final settings = getAndroidSettings(forceLocationManager: true);
      position = await Geolocator.getCurrentPosition(locationSettings: settings);
    }
  } on TimeoutException {
    logger.d('Timeout occured when acquiring geo location');
  }

  return RequestedPosition(position, permission);
}

AndroidSettings getAndroidSettings({bool? forceLocationManager}) {
  return AndroidSettings(
    forceLocationManager: forceLocationManager ?? Config.androidFloss,
    timeLimit: Duration(seconds: 30),
  );
}

/// Ensures all preconditions needed to determine the current position.
/// If needed, location permissions are requested.
Future<LocationStatus> checkAndRequestLocationPermission(
  BuildContext context, {
  bool requestIfNotGranted = true,
}) async {
  final serviceEnabled = Config.androidFloss
      ? await isNonGoogleLocationServiceEnabled()
      : await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    if (requestIfNotGranted && context.mounted) {
      final bool? result = await showDialog<bool>(
        context: context,
        builder: (context) => const LocationServiceDialog(),
      );
      if (result == true) {
        await Geolocator.openLocationSettings();
      }
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationStatus.notSupported;
    }
  }

  if (requestIfNotGranted) {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return LocationPermission.deniedForever.toLocationStatus();
    } else if (permission == LocationPermission.denied) {
      final requestResult = await Geolocator.requestPermission();

      if (requestResult == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        if (context.mounted) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => RationaleDialog(rationale: t.location.activateLocationAccessRationale),
          );

          if (result == true && context.mounted) {
            return checkAndRequestLocationPermission(context, requestIfNotGranted: requestIfNotGranted);
          }
        }

        return LocationPermission.denied.toLocationStatus();
      } else if (requestResult == LocationPermission.deniedForever) {
        return LocationPermission.deniedForever.toLocationStatus();
      }

      return requestResult.toLocationStatus();
    }

    return permission.toLocationStatus();
  } else {
    final permission = await Geolocator.checkPermission();
    return permission.toLocationStatus();
  }
}

Future<void> openSettingsToGrantPermissions(BuildContext userInteractContext) async {
  await Geolocator.openAppSettings();
}
