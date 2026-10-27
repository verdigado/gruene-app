import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';

const bearerPrefix = 'Bearer';

class AuthInterceptor implements Interceptor {
  final AuthRepository _authRepository = AuthRepository();
  final String? _accessToken;

  AuthInterceptor(this._accessToken);

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final accessToken = _accessToken ?? await _authRepository.getAccessToken();
    final updatedRequest = applyHeader(
      chain.request,
      HttpHeaders.authorizationHeader,
      '$bearerPrefix ${accessToken!}',
      override: false,
    );

    return chain.proceed(updatedRequest);
  }
}
