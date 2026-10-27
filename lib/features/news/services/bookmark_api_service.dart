import 'package:gruene_app/app/services/api/api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<Bookmark> createBookmark(String newsId) async => postToApi(
  request: (api) => api.v1BookmarksPost(
    body: CreateBookmark(type: BookmarkType.news, itemId: newsId),
  ),
  map: (data) => data,
);

Future<void> deleteBookmark(String bookmarkId) async =>
    deleteFromApi(request: (api) => api.v1BookmarksBookmarkIdDelete(bookmarkId: bookmarkId));
