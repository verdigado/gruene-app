import 'package:equatable/equatable.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class BookmarkState extends Equatable {
  final bool isLoading;
  final List<Bookmark> bookmarks;
  final Set<String> bookmarkedNewsIds;
  final String? error;

  const BookmarkState({
    this.isLoading = false,
    this.bookmarks = const [],
    this.bookmarkedNewsIds = const {},
    this.error,
  });

  BookmarkState copyWith({bool? isLoading, List<Bookmark>? bookmarks, Set<String>? bookmarkedNewsIds, String? error}) {
    return BookmarkState(
      isLoading: isLoading ?? this.isLoading,
      bookmarks: bookmarks ?? this.bookmarks,
      bookmarkedNewsIds: bookmarkedNewsIds ?? this.bookmarkedNewsIds,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, bookmarks, bookmarkedNewsIds, error];
}
