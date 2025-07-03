import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

Future<NewsModel> fetchNewsById(String newsId) async => getFromApi(
  request: (api) => api.v1NewsNewsIdGet(newsId: newsId),
  map: NewsModel.fromApi,
);

Future<List<NewsModel>> fetchNews({String? query, bool bookmarked = false}) async => getFromApi(
  request: (api) => api.v1NewsGet(search: query, limit: 100, bookmarked: bookmarked ? V1NewsGetBookmarked.$true : null),
  map: (data) => data.data.map(NewsModel.fromApi).toList(),
);
