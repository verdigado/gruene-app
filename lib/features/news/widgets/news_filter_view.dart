import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/date_range_picker.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection_view.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class NewsFilterView extends StatefulWidget {
  final void Function(List<String> divisions) setSelectedDivisions;
  final List<String> divisions;
  final List<String> selectedDivisions;
  final void Function(List<String> categories) setSelectedCategories;
  final List<String> categories;
  final List<String> selectedCategories;
  final void Function(DateTimeRange? dateRange) setDateRange;
  final DateTimeRange? dateRange;

  const NewsFilterView({
    super.key,
    required this.setSelectedDivisions,
    required this.divisions,
    required this.selectedDivisions,
    required this.setSelectedCategories,
    required this.categories,
    required this.selectedCategories,
    required this.setDateRange,
    required this.dateRange,
  });

  @override
  State<NewsFilterView> createState() => _NewsFilterViewState();
}

class _NewsFilterViewState extends State<NewsFilterView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        SelectionView(
          setSelectedOptions: widget.setSelectedDivisions,
          title: t.news.divisions,
          options: widget.divisions,
          selectedOptions: widget.selectedDivisions,
        ),
        SelectionView(
          setSelectedOptions: widget.setSelectedCategories,
          title: t.news.categories,
          options: widget.categories,
          selectedOptions: widget.selectedCategories,
        ),
        SectionTitle(title: t.news.publicationDate),
        Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: DateRangeFilter(
            setDateRange: widget.setDateRange,
            dateRange: widget.dateRange,
          ),
        ),
      ],
    );
  }
}
