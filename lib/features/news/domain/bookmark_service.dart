import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<List<Bookmark>> fetchBookmarks() async =>
    getFromApi(request: (api) => api.v1BookmarksGet(), map: (data) => data.data);

Future<void> createBookmark(String newsId) async => postToApi(
  request: (api) => api.v1BookmarksPost(
    body: CreateBookmark(type: createBookmarkTypeFromJson(BookmarkType.news.value), itemId: newsId),
  ),
);

Future<void> deleteBookmark(String bookmarkId) async =>
    deleteFromApi(request: (api) => api.v1BookmarksBookmarkIdDelete(bookmarkId: bookmarkId));
