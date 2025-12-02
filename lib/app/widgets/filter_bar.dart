import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/rounded_icon_button.dart';
import 'package:gruene_app/app/widgets/search_bar.dart';

class FilterBar extends StatelessWidget {
  final Widget filterDialog;
  final bool modified;
  final FilterModel<String> searchFilter;
  final FilterModel<bool>? bookmarkFilter;
  final bool loading;

  const FilterBar({
    super.key,
    required this.filterDialog,
    required this.modified,
    required this.searchFilter,
    this.bookmarkFilter,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkFilter = this.bookmarkFilter;

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        spacing: 8,
        children: [
          Flexible(child: CustomSearchBar(searchFilter: searchFilter)),
          if (bookmarkFilter != null)
            RoundedIconButton(
              onPressed: () => bookmarkFilter.update(!bookmarkFilter.selected),
              icon: Icons.bookmark_outline,
              iconColor: ThemeColors.textDisabled,
              backgroundColor: theme.colorScheme.surface,
              selected: bookmarkFilter.selected,
              width: 40,
            ),
          loading ? CircularProgressIndicator() : RoundedIconButton(
            icon: Icons.filter_list,
            iconColor: modified ? theme.colorScheme.secondary : ThemeColors.textDisabled,
            backgroundColor: theme.colorScheme.surface,
            width: 40,
            onPressed: () => showFullScreenDialog(context, (_) => filterDialog),
          ),
        ],
      ),
    );
  }
}
