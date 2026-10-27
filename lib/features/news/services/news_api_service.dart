import 'package:gruene_app/app/services/api/api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<News> fetchNewsById(String newsId) async => getFromApi(request: (api) => api.v1NewsNewsIdGet(newsId: newsId));

Future<List<News>> fetchNews({String? query, bool bookmarked = false}) async => getFromApi(
  request: (api) =>
      api.v1NewsGet(search: query, limit: 1000, bookmarked: bookmarked ? V1NewsGetBookmarked.$true : null),
  map: (data) => data.data,
);
