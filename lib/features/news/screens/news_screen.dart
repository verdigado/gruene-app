import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/screens/tab_screen.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';
import 'package:gruene_app/features/news/domain/news_api_service.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/utils/utils.dart';
import 'package:gruene_app/features/news/widgets/news_list.dart';
import 'package:gruene_app/features/news/widgets/news_search_filter_bar.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsScreenContainer extends StatelessWidget {
  const NewsScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScreen(
      appBarBuilder: (PreferredSizeWidget tabBar) => MainAppBar(title: t.news.news, tabBar: tabBar),
      tabs: [
        TabModel(
          label: t.news.latest,
          view: Builder(
            builder: (context) => FutureLoadingScreen<List<NewsModel>>(
              load: fetchNews,
              buildChild: (List<NewsModel> news) => NewsScreen(news: news),
            ),
          ),
        ),
        TabModel(
          label: t.news.bookmarked,
          view: Builder(
            builder: (context) => FutureLoadingScreen<List<NewsModel>>(
              load: () => fetchNews(bookmarked: true),
              buildChild: (List<NewsModel> news) => NewsScreen(news: news),
            ),
          ),
        ),
      ],
    );
  }
}

class NewsScreen extends StatefulWidget {
  final List<NewsModel> news;

  const NewsScreen({super.key, required this.news});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _showBookmarked = false;
  String _query = '';
  late List<Division> _selectedDivisions;
  List<NewsCategory> _selectedCategories = [];
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    final divisions = widget.news.divisions();
    _selectedDivisions = [divisions.bundesverband()];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NewsSearchFilterBar(
            allNews: widget.news,
            setQuery: (query) => setState(() => _query = query),
            query: _query,
            setShowBookmarked: (showBookmarked) => setState(() => _showBookmarked = showBookmarked),
            showBookmarked: _showBookmarked,
            setSelectedDivisions: (divisions) => setState(() => _selectedDivisions = divisions),
            selectedDivisions: _selectedDivisions,
            setSelectedCategories: (categories) => setState(() => _selectedCategories = categories),
            selectedCategories: _selectedCategories,
            setDateRange: (DateTimeRange? dateRange) => setState(() => _dateRange = dateRange),
            dateRange: _dateRange,
          ),
          SizedBox(height: 8),
          Expanded(
            child: NewsList(
              allNews: widget.news,
              query: _query,
              selectedDivisions: _selectedDivisions,
              selectedCategories: _selectedCategories,
              dateRange: _dateRange,
              showBookmarked: _showBookmarked,
            ),
          ),
        ],
      ),
    );
  }
}
