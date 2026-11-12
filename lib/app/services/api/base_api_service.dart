import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

abstract class BaseApiService {
  final grueneApi = GetIt.I<GrueneApi>();

  Future<T> send<S, T>({required Future<Response<S>> Function(GrueneApi api) request, T Function(S data)? map}) async {
    final response = await request(grueneApi);

    handleApiError(response);

    final body = response.body as S;
    return map == null ? body as T : map(body);
  }

  Response<T> handleApiError<T>(Response<T> response) {
    if (!response.isSuccessful || (!_isNullable<T>() && response.body == null)) {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.error?.toString(),
        url: response.base.request?.url,
      );
    }
    return response;
  }

  bool _isNullable<T>() => null is T;
}

class ApiException implements Exception {
  final int statusCode;
  final String? message;
  final Uri? url;

  ApiException({required this.statusCode, this.message, this.url});

  /// The response's error body, or null if it isn't a JSON object, like a proxy's HTML error page.
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
