import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/news/bloc/bookmark_bloc.dart';
import 'package:gruene_app/features/news/bloc/bookmark_event.dart';
import 'package:gruene_app/features/news/bloc/bookmark_state.dart';

class BookmarkButton extends StatelessWidget {
  final String newsId;

  const BookmarkButton({
    super.key,
    required this.newsId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        final isBookmarked = state.bookmarkedNewsIds.contains(newsId);
        final bookmarkId = state.bookmarks
            .firstWhereOrNull(
              (b) => b.itemId == newsId,
            )
            ?.id;

        return IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark_added : Icons.bookmark_add_outlined,
            color: theme.colorScheme.surface,
            size: 24,
          ),
          onPressed: state.isLoading
              ? null
              : () {
                  final bloc = context.read<BookmarkBloc>();
                  if (isBookmarked) {
                    bloc.add(RemoveBookmark(bookmarkId!, newsId));
                  } else {
                    bloc.add(AddBookmark(newsId));
                  }
                },
        );
      },
    );
  }
}
