import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/date_range_picker.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection_view.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsFilterView extends StatefulWidget {
  final List<NewsModel> allNews;
  final void Function(List<Division> divisions) setSelectedDivisions;
  final List<Division> selectedDivisions;
  final void Function(List<NewsCategory> categories) setSelectedCategories;
  final List<NewsCategory> selectedCategories;
  final void Function(DateTimeRange? dateRange) setDateRange;
  final DateTimeRange? dateRange;

  const NewsFilterView({
    super.key,
    required this.allNews,
    required this.setSelectedDivisions,
    required this.selectedDivisions,
    required this.setSelectedCategories,
    required this.selectedCategories,
    required this.setDateRange,
    required this.dateRange,
  });

  @override
  State<NewsFilterView> createState() => _NewsFilterViewState();
}

class _NewsFilterViewState extends State<NewsFilterView> {
  late List<Division> _localSelectedDivisions;
  late List<NewsCategory> _localSelectedCategories;
  late DateTimeRange? _localDateRange;

  @override
  void initState() {
    super.initState();
    _localSelectedDivisions = widget.selectedDivisions;
    _localSelectedCategories = widget.selectedCategories;
    _localDateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    final divisions = widget.allNews.map((it) => it.division).nonNulls.toSet().toList();
    final categories = widget.allNews.map((it) => it.categories).expand((it) => it).toSet().toList();
    final theme = Theme.of(context);
    return ListView(
      children: [
        SelectionView(
          setSelectedOptions: (divisions) {
            setState(() => _localSelectedDivisions = divisions);
            widget.setSelectedDivisions(divisions);
          },
          title: t.news.divisions,
          options: divisions,
          selectedOptions: _localSelectedDivisions,
          getLabel: (division) => division.name1,
        ),
        SelectionView(
          setSelectedOptions: (categories) {
            setState(() => _localSelectedCategories = categories);
            widget.setSelectedCategories(categories);
          },
          title: t.news.categories,
          options: categories,
          selectedOptions: _localSelectedCategories,
          getLabel: (category) => category.label,
        ),
        SectionTitle(title: t.news.publicationDate),
        Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: DateRangeFilter(
            setDateRange: (dateRange) {
              setState(() => _localDateRange = dateRange);
              widget.setDateRange(dateRange);
            },
            dateRange: _localDateRange,
          ),
        ),
      ],
    );
  }
}
