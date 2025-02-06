import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/features/news/domain/news_api_service.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/widgets/news_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class NewsList extends StatelessWidget {
  final String? division;
  final String? search;
  final String? category;
  final DateTime? start;
  final DateTime? end;
  final bool bookmarked;

  const NewsList({super.key, this.division, this.search, this.category, this.start, this.end, this.bookmarked = false});

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: () => fetchNews(
        division: division,
        search: search,
        category: category,
        start: start,
        end: end,
        bookmarked: bookmarked,
      ),
      buildChild: (List<NewsModel>? data) {
        if (data == null || data.isEmpty) {
          return ErrorScreen(error: t.news.noResults, retry: fetchNews);
        }
        final categories = data.map((it) => it.categories).expand((it) => it).toSet();
        print(categories);
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => NewsCard(news: data[index]),
        );
      },
    );
  }
}
