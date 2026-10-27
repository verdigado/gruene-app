import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<T> getFromApi<S, T>({
  required Future<Response<S>> Function(GrueneApi api) request,
  T Function(S data)? map,
}) async {
  final GrueneApi api = GetIt.I<GrueneApi>();

  final response = await request(api);
  final body = response.body;

  if (!response.isSuccessful || body == null) {
    throw Exception('${t.error.apiError(statusCode: response.statusCode)}\n${response.base.request?.url}');
  }

  return (map ?? (data) => data as T)(body);
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
