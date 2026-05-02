import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/full_width_image.dart';
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
            child: ListView(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: NewsDetailImage(news: news),
                ),
                Stack(
                  children: [
                    Container(
                      padding: defaultScreenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          division != null ? Text(division.shortDisplayName()) : Container(),
                          Text(
                            news.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: 'GrueneTypeNeue',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            t.common.updatedAt(date: news.createdAt.formattedDate),
                            style: theme.textTheme.labelSmall,
                          ),
                          CustomHtml(data: news.content),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: BookmarkButton(newsId: news.id, color: ThemeColors.text),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NewsDetailImage extends StatelessWidget {
  final NewsModel news;

  const NewsDetailImage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final image = news.image;
    if (image == null) {
      return Image.asset('assets/graphics/placeholder.png', height: 256, fit: BoxFit.fitWidth);
    }
    final imageVariant = image.variant('wide');
    return FullWidthImage(image: imageVariant.url, heightRatio: imageVariant.height / imageVariant.width);
  }
}
