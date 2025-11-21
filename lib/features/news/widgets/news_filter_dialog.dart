import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/date_range_filter.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/selection_view.dart';
import 'package:gruene_app/features/news/repository/news_repository.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

// TODO Temporary workaround for the categories prominently highlighted in the filter dialog
// The categories are Bundesvorstand, Digitalisierung and Wahlen & Wahlkampf
const prominentCategoryIds = ['2680259', '88764', '653'];

class NewsFilterDialog extends StatefulWidget {
  final FilterModel<List<Division>> divisionFilter;
  final FilterModel<List<NewsCategory>> categoryFilter;
  final FilterModel<DateTimeRange?> dateRangeFilter;

  const NewsFilterDialog({
    super.key,
    required this.divisionFilter,
    required this.categoryFilter,
    required this.dateRangeFilter,
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
    _localSelectedDivisions = widget.divisionFilter.selected;
    _localSelectedCategories = widget.categoryFilter.selected;
    _localDateRange = widget.dateRangeFilter.selected;
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
    final divisions = widget.divisionFilter.values;
    final divisionBundesverband = divisions.bundesverband();
    final divisionsLandesverband = divisions.filterByLevel(DivisionLevel.lv);
    final divisionsKreisverband = divisions.filterByLevel(DivisionLevel.kv);

    final categories = widget.categoryFilter.values;
    final prominentCategories = categories.where((it) => prominentCategoryIds.contains(it.id)).toList();
    final moreCategories = categories.where((it) => !prominentCategoryIds.contains(it.id)).toList();

    final filtersModified =
        widget.divisionFilter.modified(_localSelectedDivisions) ||
        widget.categoryFilter.modified(_localSelectedCategories) ||
        widget.dateRangeFilter.modified(_localDateRange);

    return FilterDialog(
      resetFilters: resetFilters,
      modified: filtersModified,
      children: [
        SelectionView(
          setSelectedOptions: setDivisions,
          title: t.news.divisions,
          options: [divisionBundesverband, ...divisionsLandesverband],
          moreOptionsTitle: t.news.moreDivisions,
          moreOptions: divisionsKreisverband,
          selectedOptions: _localSelectedDivisions,
          getLabel: (division) => division.level.value == 'BV' ? division.name2 : '${division.name1} ${division.name2}',
        ),
        SelectionView(
          setSelectedOptions: (categories) {
            setState(() => _localSelectedCategories = categories);
            widget.categoryFilter.update(categories);
          },
          title: t.news.categories,
          options: prominentCategories,
          moreOptionsTitle: t.news.moreCategories,
          moreOptions: moreCategories,
          selectedOptions: _localSelectedCategories,
          getLabel: (category) => category.label,
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
