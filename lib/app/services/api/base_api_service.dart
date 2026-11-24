import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

abstract class BaseApiService {
  final grueneApi = GetIt.I<GrueneApi>();

  Future<T> send<S, T>({required Future<Response<S>> Function(GrueneApi api) request, T Function(S data)? map}) async {
    final body = _requireBody(await request(grueneApi));
    return map == null ? body as T : map(body);
  }

  Response<T> handleApiError<T>(Response<T> response) {
    _requireBody(response);
    return response;
  }

  T _requireBody<T>(Response<T> response) {
    final body = response.body;
    if (!response.isSuccessful || body is! T) {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.error?.toString(),
        url: response.base.request?.url,
      );
    }
    return body;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String? message;
  final Uri? url;

  ApiException({required this.statusCode, this.message, this.url});

  Map<String, dynamic>? get body {
    try {
      final decoded = jsonDecode(message ?? '');
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => 'ApiException($statusCode) on $url: $message';
}
