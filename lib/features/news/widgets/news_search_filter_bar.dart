import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/rounded_icon_button.dart';
import 'package:gruene_app/app/widgets/search_bar.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/utils/utils.dart';
import 'package:gruene_app/features/news/widgets/news_filter_dialog.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsSearchFilterBar extends StatelessWidget {
  final List<NewsModel> allNews;
  final void Function(String query) setQuery;
  final String query;
  final void Function(bool showBookmarked) setShowBookmarked;
  final bool showBookmarked;
  final void Function(List<Division>) setSelectedDivisions;
  final List<Division> selectedDivisions;
  final void Function(List<NewsCategory> categories) setSelectedCategories;
  final List<NewsCategory> selectedCategories;
  final void Function(DateTimeRange? dateRange) setDateRange;
  final DateTimeRange? dateRange;

  const NewsSearchFilterBar({
    super.key,
    required this.allNews,
    required this.setQuery,
    required this.query,
    required this.setShowBookmarked,
    required this.showBookmarked,
    required this.setSelectedDivisions,
    required this.selectedDivisions,
    required this.setSelectedCategories,
    required this.selectedCategories,
    required this.setDateRange,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customFilterSelected = isCustomFilterSelected(selectedDivisions, selectedCategories, dateRange);
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            // TODO debounce
            child: CustomSearchBar(setQuery: setQuery, query: query),
          ),
          // TODO #213: Add bookmarking functionality
          // SizedBox(width: 8),
          // RoundedIconButton(
          //   onPressed: () => setState(() => showBookmarked = !showBookmarked),
          //   icon: Icons.bookmark_outline,
          //   iconColor: ThemeColors.textDisabled,
          //   backgroundColor: theme.colorScheme.surface,
          //   selected: showBookmarked,
          //   width: 40,
          // ),
          SizedBox(width: 8),
          RoundedIconButton(
            icon: Icons.tune,
            iconColor: customFilterSelected ? theme.colorScheme.secondary : ThemeColors.textDisabled,
            backgroundColor: theme.colorScheme.surface,
            width: 40,
            onPressed: () => showFullScreenDialog(
              context,
              (_) => NewsFilterDialog(
                allNews: allNews,
                setSelectedDivisions: setSelectedDivisions,
                selectedDivisions: selectedDivisions,
                setSelectedCategories: setSelectedCategories,
                selectedCategories: selectedCategories,
                setDateRange: setDateRange,
                dateRange: dateRange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
