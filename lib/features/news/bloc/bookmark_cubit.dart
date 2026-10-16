import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

// Stores the bookmarks added/deleted in this session
class BookmarkCubit extends Cubit<Map<String, Bookmark?>> {
  BookmarkCubit() : super(const {});

  Bookmark? bookmarkOf(News news) => state.containsKey(news.id) ? state[news.id] : news.bookmark;

  bool isBookmarked(News news) => bookmarkOf(news) != null;

  void setBookmark(String newsId, Bookmark? bookmark) => emit({...state, newsId: bookmark});
}
