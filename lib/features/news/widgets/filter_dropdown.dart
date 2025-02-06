import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/choice_picker.dart';
import 'package:gruene_app/app/widgets/date_range_picker.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class FilterOption {
  final String title;
  final Widget widget;

  const FilterOption({required this.title, required this.widget});
}

class FilterTitle extends StatelessWidget {
  final String title;

  const FilterTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 52,
      color: theme.colorScheme.surfaceDim,
      padding: EdgeInsets.only(left: 24, top: 12, right: 24, bottom: 6),
      alignment: Alignment.centerLeft,
      child: Text(title, style: theme.textTheme.titleMedium),
    );
  }
}

class FilterContainer extends StatelessWidget {
  final Widget child;

  const FilterContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.symmetric(horizontal: BorderSide(color: ThemeColors.textLight, width: 1)),
      ),
      child: child,
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final void Function(DateTimeRange? dateRange) setDateRange;
  final DateTimeRange? dateRange;

  final List<String> categories;
  final divisions = [
    t.common.divisionBundesverband,
    t.common.divisionLandesverband,
    t.common.divisionKreisverband,
    t.common.divisionOrtsverband,
  ];

  FilterDropdown({
    super.key,
    required this.categories,
    required this.setDateRange,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterTitle(title: t.news.divisions),
        FilterContainer(
          child: ChoiceFilter(setSelectedFilter: (_) {}, filterOptions: divisions, selectedFilter: divisions[1]),
        ),
        FilterTitle(title: t.news.categories),
        FilterContainer(
          child: ChoiceFilter(setSelectedFilter: (_) {}, filterOptions: categories, selectedFilter: categories[2]),
        ),
        FilterTitle(title: t.news.publicationDate),
        FilterContainer(
          child: DateRangeFilter(
            setDateRange: setDateRange,
            dateRange: dateRange,
          ),
        ),
      ],
    );
  }
}
