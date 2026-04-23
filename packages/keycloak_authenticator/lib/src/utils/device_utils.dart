import 'dart:io';
import 'package:keycloak_authenticator/src/enums/device_os_enum.dart';

class DeviceUtils {
  DeviceUtils._();

  static DeviceOs getDeviceOs() {
    if (Platform.isIOS) {
      return DeviceOs.ios;
    } else if (Platform.isAndroid) {
      return DeviceOs.android;
    }
    throw Exception("${Platform.operatingSystem} is not supported");
  }
}
