import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/features/news/domain/news_api_service.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/widgets/news_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension IsBetween on DateTime {
  bool isBetween(DateTimeRange dateRange) {
    final safeEndDate = dateRange.end.copyWith(day: dateRange.end.day + 1);
    return !dateRange.start.isAfter(this) && safeEndDate.isAfter(this);
  }
}

extension ContainsAny<T> on List<T> {
  bool containsAny(List<T> other) {
    return any((element) => other.contains(element));
  }
}

class NewsList extends StatelessWidget {
  final List<NewsModel> allNews;
  final String query;
  final bool bookmarked;
  final List<Division> selectedDivisions;
  final List<NewsCategory> selectedCategories;
  final DateTimeRange? dateRange;

  const NewsList({
    super.key,
    required this.allNews,
    required this.query,
    required this.bookmarked,
    required this.selectedDivisions,
    required this.selectedCategories,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: query.isNotEmpty ? () => fetchNews(query: query) : () async => allNews,
      buildChild: (List<NewsModel> data) {
        print(selectedDivisions);
        final news = data
            .where(
              (it) =>
                  (selectedDivisions.isEmpty || selectedDivisions.contains(it.division)) &&
                  (selectedCategories.isEmpty || selectedCategories.containsAny(it.categories)) &&
                  (!bookmarked || it.bookmarked) &&
                  (dateRange == null || it.createdAt.isBetween(dateRange!)),
            )
            .toList();
        if (news.isEmpty) {
          return ErrorScreen(error: t.news.noResults, retry: fetchNews);
        }
        return ListView.builder(
          itemCount: news.length,
          itemBuilder: (context, index) => NewsCard(news: news[index]),
        );
      },
    );
  }
}
