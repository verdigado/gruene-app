import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/features/news/models/news_model.dart';

Future<NewsModel> fetchNewsById(String newsId) async => getFromApi(
      request: (api) => api.v1NewsNewsIdGet(newsId: newsId),
      map: NewsModel.fromApi,
    );

Future<List<NewsModel>> fetchNews() async => getFromApi(
      request: (api) => api.v1NewsGet(),
      map: (data) => data.data.map(NewsModel.fromApi).toList(),
    );
