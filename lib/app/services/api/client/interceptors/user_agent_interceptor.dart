import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart' as chopper;
import 'package:package_info_plus/package_info_plus.dart';

String _getSystemDescription() {
  if (Platform.isAndroid) {
    return 'Android';
  } else if (Platform.isIOS) {
    return 'iOS';
  } else {
    return 'unknown_OS';
  }
}

Future<String> _getUserAgentString() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.packageName} ${packageInfo.version}+${packageInfo.buildNumber} (${_getSystemDescription()}, ${packageInfo.installerStore})';
}

class UserAgentInterceptor implements chopper.Interceptor {
  final String? userAgent;

  UserAgentInterceptor([this.userAgent]);

  @override
  FutureOr<chopper.Response<BodyType>> intercept<BodyType>(chopper.Chain<BodyType> chain) async {
    final userAgentHeaderValue = userAgent ?? await _getUserAgentString();
    final updatedRequest = chopper.applyHeader(
      chain.request,
      HttpHeaders.userAgentHeader,
      userAgentHeaderValue,
      override: true,
    );

    return chain.proceed(updatedRequest);
  }
}
