import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/news/bloc/bookmark_cubit.dart';
import 'package:gruene_app/features/news/services/bookmark_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class BookmarkButton extends StatefulWidget {
  final News news;
  final Color? color;

  const BookmarkButton({super.key, required this.news, this.color});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool _pending = false;

  Future<void> _toggle() async {
    final news = widget.news;
    final cubit = context.read<BookmarkCubit>();
    final bookmarkId = cubit.bookmarkOf(news)?.id;

    setState(() => _pending = true);
    try {
      if (bookmarkId != null) {
        await deleteBookmark(bookmarkId);
        cubit.setBookmark(news.id, null);
      } else {
        final bookmark = await createBookmark(news.id);
        cubit.setBookmark(news.id, bookmark);
      }
    } catch (error) {
      if (mounted) showSnackBar(context: context, text: getErrorMessage(error));
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.surface;
    final bookmarked = context.select((BookmarkCubit cubit) => cubit.isBookmarked(widget.news));

    return IconButton(
      icon: _pending
          ? Padding(
              padding: const EdgeInsets.all(4),
              child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color)),
            )
          : Icon(bookmarked ? Icons.bookmark_added : Icons.bookmark_add_outlined, color: color, size: 24),
      onPressed: _pending ? null : _toggle,
    );
  }
}
