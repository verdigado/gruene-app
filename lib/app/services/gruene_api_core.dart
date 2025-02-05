import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/services/access_token_authenticator.dart';
import 'package:gruene_app/app/services/interceptors/auth_interceptor.dart';
import 'package:gruene_app/app/services/interceptors/keep_alive_interceptor.dart';
import 'package:gruene_app/app/services/interceptors/user_agent_interceptor.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<GrueneApi> createGrueneApiClient() async {
  List<Interceptor> interceptors = [
    UserAgentInterceptor(),
    KeepAliveInterceptor(),
    AuthInterceptor(Config.grueneApiAccessToken),
  ];

  return GrueneApi.create(
    baseUrl: Uri.parse(Config.grueneApiUrl),
    authenticator: Config.grueneApiAccessToken == null ? AccessTokenAuthenticator() : null,
    interceptors: interceptors,
  );
}
