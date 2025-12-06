import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

abstract class GrueneApiBaseService {
  late GrueneApi grueneApi;

  GrueneApiBaseService() {
    grueneApi = GetIt.I<GrueneApi>();
  }

  Future<T> getFromApi<S, T>({
    required Future<Response<S>> Function(GrueneApi api) apiRequest,
    required T Function(S data) map,
  }) async {
    final response = await apiRequest(grueneApi);

    handleApiError(response);

    final body = response.body as S;
    return map(body);
  }

  Response<T> handleApiError<T>(Response<T> response) {
    if (!response.isSuccessful || (!_isNullable<T>() && response.body == null)) {
      throw ApiException(statusCode: response.statusCode, message: response.error.toString());
    }
    return response;
  }

  bool _isNullable<T>() => null is T;
}

class ApiException implements Exception {
  int statusCode;
  String message;
  ApiException({required this.statusCode, this.message = ''});
}
