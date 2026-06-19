import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/date_range_filter.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/features/news/repository/news_repository.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsFilterDialog extends StatefulWidget {
  final SelectionFilterModel<List<Division>, List<Division>> divisionFilter;
  final SelectionFilterModel<List<NewsCategory>, List<NewsCategory>> categoryFilter;
  final FilterModel<DateTimeRange?> dateRangeFilter;
  final String Function(Division division) getDivisionLabel;

  const NewsFilterDialog({
    super.key,
    required this.divisionFilter,
    required this.categoryFilter,
    required this.dateRangeFilter,
    required this.getDivisionLabel,
  });

  @override
  State<NewsFilterDialog> createState() => _NewsFilterDialogState();
}

// showFullScreenDialog creates a new BuildContext, such that state updates in the parent do not update widgets in the dialog
// We therefore need a local copy to reflect the state changes here as well
class _NewsFilterDialogState extends State<NewsFilterDialog> {
  late List<Division> _localSelectedDivisions;
  late List<NewsCategory> _localSelectedCategories;
  late DateTimeRange? _localDateRange;

  @override
  void initState() {
    super.initState();
    _localSelectedDivisions = widget.divisionFilter.current;
    _localSelectedCategories = widget.categoryFilter.current;
    _localDateRange = widget.dateRangeFilter.current;
  }

  void setDivisions(List<Division> divisions) {
    widget.divisionFilter.update(divisions);
    setState(() => _localSelectedDivisions = divisions);
    writeDivisionFilterKeys(divisions);
  }

  void resetFilters() {
    setDivisions(widget.divisionFilter.initial);
    widget.categoryFilter.reset();
    widget.dateRangeFilter.reset();
    setState(() {
      _localSelectedCategories = widget.categoryFilter.initial;
      _localDateRange = widget.dateRangeFilter.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoryFilter.values;

    final filtersModified =
        widget.divisionFilter.modified(_localSelectedDivisions) ||
        widget.categoryFilter.modified(_localSelectedCategories) ||
        widget.dateRangeFilter.modified(_localDateRange);

    return FilterDialog(
      resetFilters: resetFilters,
      modified: filtersModified,
      children: [
        FilterSection(
          title: t.divisions.divisions,
          child: MultiSelection(
            selected: _localSelectedDivisions,
            setSelected: setDivisions,
            items: widget.divisionFilter.values.sortByLevel(),
            compare: (division1, division2) => division1.id == division2.id,
            filter: (division, query) => division.matches(query),
            itemAsString: widget.getDivisionLabel,
            label: t.divisions.divisions,
          ),
        ),
        FilterSection(
          title: t.news.categories,
          child: MultiSelection(
            selected: _localSelectedCategories,
            setSelected: (categories) {
              setState(() => _localSelectedCategories = categories);
              widget.categoryFilter.update(categories);
            },
            items: categories,
            compare: (category1, category2) => category1.id == category2.id,
            filter: (category, query) => category.label.matches(query),
            itemAsString: (category) => category.label,
            label: t.news.categories,
          ),
        ),
        DateRangeFilter(
          title: t.news.publicationDate,
          dateRange: _localDateRange,
          lastDate: DateTime.now(),
          setDateRange: (dateRange) {
            setState(() => _localDateRange = dateRange);
            widget.dateRangeFilter.update(dateRange);
          },
        ),
      ],
    );
  }
}
