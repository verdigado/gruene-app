import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class ChoiceFilter extends StatelessWidget {
  final void Function(String? selected) setSelectedFilter;
  final List<String> filterOptions;
  final String? selectedFilter;

  const ChoiceFilter({
    super.key,
    required this.setSelectedFilter,
    required this.filterOptions,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 16),
          ...filterOptions.map(
            (filter) => Container(
              margin: EdgeInsets.only(right: 16),
              child: ChoiceChip(
                onSelected: (selected) => setSelectedFilter(selected ? filter : null),
                selected: filter == selectedFilter,
                label: Text(
                  filter,
                  style: theme.textTheme.bodyMedium
                      ?.apply(color: filter == selectedFilter ? theme.colorScheme.surface : ThemeColors.text),
                ),
                backgroundColor: theme.colorScheme.surfaceDim,
                selectedColor: theme.colorScheme.secondary,
                checkmarkColor: theme.colorScheme.surface,
                shape: StadiumBorder(),
                side: BorderSide(color: theme.colorScheme.surfaceDim),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
