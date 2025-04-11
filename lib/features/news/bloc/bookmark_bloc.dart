import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/features/news/bloc/bookmark_event.dart';
import 'package:gruene_app/features/news/bloc/bookmark_state.dart';
import 'package:gruene_app/features/news/domain/bookmark_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  BookmarkBloc() : super(const BookmarkState()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<AddBookmark>(_onAddBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final bookmarks = await fetchBookmarks();
      final newsBookmarks = bookmarks
          .where(
            (b) => b.type == BookmarkType.news,
          )
          .toList();

      final bookmarkedIds = newsBookmarks.map((b) => b.itemId).toSet();

      emit(
        state.copyWith(
          isLoading: false,
          bookmarks: newsBookmarks,
          bookmarkedNewsIds: bookmarkedIds,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddBookmark(
    AddBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await createBookmark(event.newsId);

      await _onLoadBookmarks(LoadBookmarks(), emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await deleteBookmark(event.bookmarkId);

      final newBookmarkedIds = state.bookmarkedNewsIds.toSet()..remove(event.newsId);

      final newBookmarks = state.bookmarks.where((b) => b.id != event.bookmarkId).toList();

      emit(
        state.copyWith(
          isLoading: false,
          bookmarks: newBookmarks,
          bookmarkedNewsIds: newBookmarkedIds,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
