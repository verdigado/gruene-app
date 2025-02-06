import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/features/news/models/news_model.dart';

Future<NewsModel> fetchNewsById(String newsId) async => getFromApi(
      request: (api) => api.v1NewsNewsIdGet(newsId: newsId),
      map: NewsModel.fromApi,
    );

Future<List<NewsModel>> fetchNews({
  String? division,
  String? search,
  String? category,
  DateTime? start,
  DateTime? end,
  bool? bookmarked,
}) async {
  final List<String> categories = category == null ? [] : [category];
  return getFromApi(
    // TODO Actually use all arguments (start, end, bookmarked)
    request: (api) => api.v1NewsGet(divisionKey: division, search: search, category: categories),
    map: (data) => data.data.map(NewsModel.fromApi).toList(),
  );
}
