import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/features/news/domain/news_api_service.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/repository/news_repository.dart';
import 'package:gruene_app/features/news/utils/utils.dart';
import 'package:gruene_app/features/news/widgets/news_filter_dialog.dart';
import 'package:gruene_app/features/news/widgets/news_list.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsScreenContainer extends StatelessWidget {
  const NewsScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.news.news),
      body: FutureLoadingScreen(
        load: () async => (await fetchNews(), await readDivisionFilterKeys()),
        buildChild: (params, _) {
          final (news, divisionFilterKeys) = params;
          final initialDivisionFilters = divisionFilterKeys == null
              ? [news.divisions().bundesverband()]
              : news.divisions().where((division) => divisionFilterKeys.contains(division.divisionKey)).toList();
          return NewsScreen(news: news, initialDivisionFilters: initialDivisionFilters);
        },
      ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  final List<NewsModel> news;
  final List<Division> initialDivisionFilters;

  const NewsScreen({super.key, required this.news, required this.initialDivisionFilters});

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
    _selectedDivisions = widget.initialDivisionFilters;
  }

  @override
  Widget build(BuildContext context) {
    final divisions = widget.news.divisions();
    final categories = widget.news.categories();

    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', selected: _query);
    final bookmarkFilter = FilterModel(
      update: (showBookmarked) => setState(() => _showBookmarked = showBookmarked),
      initial: false,
      selected: _showBookmarked,
    );
    final divisionFilter = FilterModel(
      update: (divisions) => setState(() => _selectedDivisions = divisions),
      initial: [divisions.bundesverband()],
      selected: _selectedDivisions,
      values: divisions,
    );
    final categoryFilter = FilterModel<List<NewsCategory>>(
      update: (categories) => setState(() => _selectedCategories = categories),
      initial: [],
      selected: _selectedCategories,
      values: categories,
    );
    final dateRangeFilter = FilterModel(
      update: (dateRange) => setState(() => _dateRange = dateRange),
      initial: null,
      selected: _dateRange,
    );

    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          FilterBar(
            searchFilter: searchFilter,
            bookmarkFilter: bookmarkFilter,
            modified: [divisionFilter, categoryFilter, dateRangeFilter].modified(),
            filterDialog: NewsFilterDialog(
              divisionFilter: divisionFilter,
              categoryFilter: categoryFilter,
              dateRangeFilter: dateRangeFilter,
            ),
          ),
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
