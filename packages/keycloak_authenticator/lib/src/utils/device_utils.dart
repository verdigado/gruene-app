import 'dart:io';

class DeviceUtils {
  DeviceUtils._();

  static String getDeviceOs() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    }
    throw Exception('${Platform.operatingSystem} is not supported');
  }
}
