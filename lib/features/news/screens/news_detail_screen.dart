import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/format_date.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/features/news/domain/news_api_service.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureLoadingScreen<NewsModel?>(
      load: () => fetchNewsById(newsId),
      buildChild: (NewsModel? news) {
        if (news == null) {
          return ErrorScreen(error: t.news.newsNotFound, retry: () => fetchNewsById(newsId));
        }
        final author = news.author;
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 288,
                        child: featuredImage(news),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            author != null ? Text(t.news.writtenBy(author: author)) : Container(),
                            Text(
                              news.title,
                              style: theme.textTheme.titleLarge,
                            ),
                            SizedBox(height: 16),
                            Text(
                              t.news.updatedAt(date: formatDate(news.createdAt)),
                              style: theme.textTheme.labelSmall,
                            ),
                            Text(
                              news.summary,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 24),
                            Html(
                              data: news.content,
                              onLinkTap: (url, _, __) => url != null ? openUrl(url, context) : null,
                              style: {
                                'body': Style(
                                  margin: Margins.zero,
                                ),
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   right: 0,
              //   child: IconButton(
              // TODO #213: Add bookmarking functionality
              //     onPressed: () {},
              //     icon: Icon(
              //       news.bookmarked ? Icons.bookmark_added : Icons.bookmark_add_outlined,
              //       color: theme.colorScheme.surface,
              //       size: 24,
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget featuredImage(NewsModel news) {
    if (news.image != null) {
      return CachedNetworkImage(
        imageUrl: selectImageVariant(news.image!, 'wide'),
      );
    }
    return Image.asset(getPlaceholderImage(news.id));
  }
}
