import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/news/domain/news_api_service.dart';
import 'package:gruene_app/features/news/widgets/news_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsList extends StatelessWidget {
  final List<News> allNews;
  final String query;
  final bool showBookmarked;
  final List<Division> selectedDivisions;
  final List<NewsCategory> selectedCategories;
  final DateTimeRange? dateRange;

  const NewsList({
    super.key,
    required this.allNews,
    required this.query,
    required this.showBookmarked,
    required this.selectedDivisions,
    required this.selectedCategories,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final dateRange = this.dateRange;
    return FutureLoadingScreen(
      refetchKey: (query, showBookmarked),
      load: query.isNotEmpty || showBookmarked
          ? () => fetchNews(query: query, bookmarked: showBookmarked)
          : () async => allNews,
      buildChild: (data, _) {
        final news = data
            .where(
              (news) =>
                  (selectedDivisions.isEmpty || selectedDivisions.contains(news.division)) &&
                  (selectedCategories.isEmpty || selectedCategories.containsAny(news.categories)) &&
                  (dateRange == null || news.createdAt.isBetween(dateRange)),
            )
            .toList();
        if (news.isEmpty) {
          return ErrorScreen(errorMessage: t.news.noResults, retry: fetchNews);
        }
        return ListView.builder(
          itemCount: news.length,
          itemBuilder: (context, index) => NewsCard(key: ValueKey(news[index].id), news: news[index]),
        );
      },
    );
  }
}
