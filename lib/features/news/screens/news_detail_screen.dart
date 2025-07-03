import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/format_date.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/html.dart';
import 'package:gruene_app/features/news/domain/news_api_service.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/utils/utils.dart';
import 'package:gruene_app/features/news/widgets/bookmark_button.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context) {
    final newsItem = GoRouterState.of(context).extra as NewsModel?;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: MainAppBar(title: t.news.newsDetail),
      body: FutureLoadingScreen<NewsModel?>(
        load: newsItem == null ? () => fetchNewsById(newsId) : () async => newsItem,
        buildChild: (NewsModel? news, _) {
          if (news == null) {
            return ErrorScreen(errorMessage: t.news.newsNotFound, retry: () => fetchNewsById(newsId));
          }
          final division = news.division;
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListView(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FullWidthImage(news: news),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            division != null ? Text(division.shortDisplayName()) : Container(),
                            Text(
                              news.title,
                              style: theme.textTheme.titleLarge?.apply(fontFamily: 'GrueneType'),
                            ),
                            SizedBox(height: 16),
                            Text(
                              t.news.updatedAt(date: formatDate(news.createdAt)),
                              style: theme.textTheme.labelSmall,
                            ),
                            CustomHtml(data: news.content),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: BookmarkButton(newsId: news.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FullWidthImage extends StatelessWidget {
  final NewsModel news;

  const FullWidthImage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final image = news.image;
    if (image == null) {
      return Image.asset(getPlaceholderImage(news.id));
    }

    final imageVariant = image.variant('wide');
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageHeight = imageVariant.height * screenWidth / imageVariant.width;
    return CachedNetworkImage(
      placeholder: (_, _) => SizedBox(height: imageHeight),
      imageUrl: imageVariant.url,
    );
  }
}
