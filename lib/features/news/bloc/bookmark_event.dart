import 'package:equatable/equatable.dart';

abstract class BookmarkEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadBookmarks extends BookmarkEvent {}

class AddBookmark extends BookmarkEvent {
  final String newsId;

  AddBookmark(this.newsId);

  @override
  List<Object> get props => [newsId];
}

class RemoveBookmark extends BookmarkEvent {
  final String bookmarkId;
  final String newsId;

  RemoveBookmark(this.bookmarkId, this.newsId);

  @override
  List<Object> get props => [bookmarkId, newsId];
}
