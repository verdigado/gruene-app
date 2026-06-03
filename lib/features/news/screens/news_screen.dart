import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/domain/divisions_api_service.dart';
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
        load: () async => (await fetchNews(), await loadDivisions(), await readDivisionFilterKeys()),
        buildChild: (params, _) {
          final (news, divisions, divisionFilterKeys) = params;
          final initialDivisionFilters = divisionFilterKeys == null
              ? [news.divisions().bundesverband]
              : news.divisions().where((division) => divisionFilterKeys.contains(division.divisionKey)).toList();
          return NewsScreen(news: news, divisions: divisions, initialDivisionFilters: initialDivisionFilters);
        },
      ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  final List<NewsModel> news;
  final List<Division> divisions;
  final List<Division> initialDivisionFilters;

  const NewsScreen({super.key, required this.news, required this.initialDivisionFilters, required this.divisions});

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
    final categories = widget.news.categories();

    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', current: _query);
    final bookmarkFilter = FilterModel(
      update: (showBookmarked) => setState(() => _showBookmarked = showBookmarked),
      initial: false,
      current: _showBookmarked,
    );
    final divisionFilter = SelectionFilterModel(
      update: (divisions) => setState(() => _selectedDivisions = divisions),
      initial: [widget.divisions.bundesverband],
      current: _selectedDivisions,
      values: widget.divisions,
    );
    final categoryFilter = SelectionFilterModel<List<NewsCategory>, List<NewsCategory>>(
      update: (categories) => setState(() => _selectedCategories = categories),
      initial: [],
      current: _selectedCategories,
      values: categories,
    );
    final dateRangeFilter = FilterModel(
      update: (dateRange) => setState(() => _dateRange = dateRange),
      initial: null,
      current: _dateRange,
    );

    return Container(
      padding: screenPadding.copyWith(bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          FilterBar(
            searchFilter: searchFilter,
            bookmarkFilter: bookmarkFilter,
            modified: <FilterModel<dynamic>>[divisionFilter, categoryFilter, dateRangeFilter].modified(),
            filterDialog: NewsFilterDialog(
              divisionFilter: divisionFilter,
              categoryFilter: categoryFilter,
              dateRangeFilter: dateRangeFilter,
              getDivisionLabel: (division) =>
                  '${division.shortDisplayName} (${widget.news.where((news) => news.division?.id == division.id).length})',
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
