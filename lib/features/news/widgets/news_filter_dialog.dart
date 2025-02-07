import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/date_range_picker.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection_view.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

// TODO Temporary workaround for the categories prominently highlighted in the filter dialog
// The categories are Bundesvorstand, Digitalisierung and Wahlen & Wahlkampf
const prominentCategoryIds = ['2680259', '88764', '653'];

class NewsFilterDialog extends StatefulWidget {
  final List<NewsModel> allNews;
  final void Function(List<Division> divisions) setSelectedDivisions;
  final List<Division> selectedDivisions;
  final void Function(List<NewsCategory> categories) setSelectedCategories;
  final List<NewsCategory> selectedCategories;
  final void Function(DateTimeRange? dateRange) setDateRange;
  final DateTimeRange? dateRange;

  const NewsFilterDialog({
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
    _localSelectedDivisions = widget.selectedDivisions;
    _localSelectedCategories = widget.selectedCategories;
    _localDateRange = widget.dateRange;
  }

  void resetFilters() {
    final bundesverband = widget.allNews.divisions().bundesverband();
    widget.setSelectedDivisions([bundesverband]);
    widget.setSelectedCategories([]);
    widget.setDateRange(null);
    setState(() {
      _localSelectedDivisions = [bundesverband];
      _localSelectedCategories = [];
      _localDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final divisions = widget.allNews.divisions();
    final divisionBundesverband = divisions.bundesverband();
    final divisionsLandesverband = divisions.filterAndSortByLevel(DivisionLevel.lv);
    final divisionsKreisverband = divisions.filterAndSortByLevel(DivisionLevel.kv);

    final categories = widget.allNews.categories();
    final prominentCategories = categories.where((it) => prominentCategoryIds.contains(it.id)).toList();
    final moreCategories = categories.where((it) => !prominentCategoryIds.contains(it.id)).toList();

    final customFilterSelected =
        isCustomFilterSelected(_localSelectedDivisions, _localSelectedCategories, _localDateRange);

    final theme = Theme.of(context);
    return FullScreenDialog(
      appBarActions: customFilterSelected
          ? [
              TextButton(
                onPressed: resetFilters,
                child: Text(t.common.actions.reset, style: theme.textTheme.bodyLarge),
              ),
            ]
          : [],
      child: ListView(
        children: [
          SelectionView(
            setSelectedOptions: (divisions) {
              setState(() => _localSelectedDivisions = divisions);
              widget.setSelectedDivisions(divisions);
            },
            title: t.news.divisions,
            options: [divisionBundesverband, ...divisionsLandesverband],
            moreOptionsTitle: t.news.moreDivisions,
            moreOptions: divisionsKreisverband,
            selectedOptions: _localSelectedDivisions,
            getLabel: (division) =>
                division.level.value == 'BV' ? division.name2 : '${division.name1} ${division.name2}',
          ),
          SelectionView(
            setSelectedOptions: (categories) {
              setState(() => _localSelectedCategories = categories);
              widget.setSelectedCategories(categories);
            },
            title: t.news.categories,
            options: prominentCategories,
            moreOptionsTitle: t.news.moreCategories,
            moreOptions: moreCategories,
            selectedOptions: _localSelectedCategories,
            getLabel: (category) => category.label,
          ),
          SectionTitle(title: t.news.publicationDate),
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
            child: DateRangePicker(
              setDateRange: (dateRange) {
                setState(() => _localDateRange = dateRange);
                widget.setDateRange(dateRange);
              },
              dateRange: _localDateRange,
            ),
          ),
        ],
      ),
    );
  }
}
