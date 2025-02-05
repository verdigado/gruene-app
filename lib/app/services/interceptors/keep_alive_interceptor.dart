import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';

class KeepAliveInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    final updatedRequest = applyHeader(
      chain.request,
      HttpHeaders.connectionHeader,
      'keep-alive',
      override: false,
    );

    return chain.proceed(updatedRequest);
  }
}
