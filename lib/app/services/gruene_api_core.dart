import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/services/access_token_authenticator.dart';
import 'package:gruene_app/app/services/interceptors/auth_interceptor.dart';
import 'package:gruene_app/app/services/interceptors/keep_alive_interceptor.dart';
import 'package:gruene_app/app/services/interceptors/user_agent_interceptor.dart';
import 'package:gruene_app/i18n/translations.g.dart';
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

Future<T> getFromApi<S, T>({
  required Future<Response<S>> Function(GrueneApi api) request,
  required T Function(S data) map,
}) async {
  final GrueneApi api = GetIt.I<GrueneApi>();

  final response = await request(api);
  final body = response.body;

  if (!response.isSuccessful || body == null) {
    throw Exception('${t.error.apiError(statusCode: response.statusCode)}\n${response.base.request?.url}');
  }

  return map(body);
}

Future<T> postToApi<S, T>({
  required Future<Response<S>> Function(GrueneApi api) request,
  T Function(S data)? map,
}) async {
  final GrueneApi api = GetIt.I<GrueneApi>();

  final response = await request(api);
  final body = response.body;

  if (!response.isSuccessful) {
    throw Exception('${t.error.apiError(statusCode: response.statusCode)}\n${response.base.request?.url}');
  }

  if (map != null && body != null) {
    return map(body);
  }

  return null as T;
}

Future<T> deleteFromApi<S, T>({
  required Future<Response<S>> Function(GrueneApi api) request,
  T Function(S data)? map,
}) async {
  final GrueneApi api = GetIt.I<GrueneApi>();

  final response = await request(api);
  final body = response.body;

  if (!response.isSuccessful) {
    throw Exception('${t.error.apiError(statusCode: response.statusCode)}\n${response.base.request?.url}');
  }

  if (map != null && body != null) {
    return map(body);
  }

  return null as T;
}
