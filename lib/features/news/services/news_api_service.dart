import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsApiService extends BaseApiService {
  Future<News> getNewsById(String newsId) async => send(request: (api) => api.v1NewsNewsIdGet(newsId: newsId));

  Future<List<News>> getNews({String? query, bool bookmarked = false}) async => send(
    request: (api) =>
        api.v1NewsGet(search: query, limit: 1000, bookmarked: bookmarked ? V1NewsGetBookmarked.$true : null),
    map: (data) => data.data,
  );

  Future<Bookmark> createBookmark(String newsId) async => send(
    request: (api) => api.v1BookmarksPost(
      body: CreateBookmark(type: BookmarkType.news, itemId: newsId),
    ),
  );

  Future<void> deleteBookmark(String bookmarkId) async =>
      send(request: (api) => api.v1BookmarksBookmarkIdDelete(bookmarkId: bookmarkId));
}
