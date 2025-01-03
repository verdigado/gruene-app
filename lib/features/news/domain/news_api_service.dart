import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<T> get<S, T>({
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

Future<NewsModel> fetchNewsById(String newsId) async => get(
      request: (api) => api.v1NewsNewsIdGet(newsId: newsId),
      map: NewsModel.fromApi,
    );

Future<List<NewsModel>> fetchNews() async => get(
      request: (api) => api.v1NewsGet(),
      map: (data) => data.data.map(NewsModel.fromApi).toList(),
    );
