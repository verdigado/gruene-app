import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/features/news/models/news_model.dart';

Future<NewsModel> fetchNewsById(String newsId) async => getFromApi(
      request: (api) => api.v1NewsNewsIdGet(newsId: newsId),
      map: NewsModel.fromApi,
    );

Future<List<NewsModel>> fetchNews({
  String? division,
  String? query,
  String? category,
  DateTime? start,
  DateTime? end,
  bool? bookmarked,
}) async {
  final List<String> categories = category == null ? [] : [category];
  return getFromApi(
    // TODO Actually use all arguments (start, end, bookmarked)
    request: (api) => api.v1NewsGet(divisionKey: division, search: query, category: categories),
    map: (data) {
      print(data.data.map((it) => it.id));
      return data.data.map(NewsModel.fromApi).toList();
    },
  );
}
