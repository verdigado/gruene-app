import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/debouncer.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CustomSearchBar extends StatelessWidget {
  final void Function(String selected) setQuery;
  final String query;

  const CustomSearchBar({super.key, required this.setQuery, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final debouncer = Debouncer();
    return SearchBar(
      onChanged: (query) => debouncer.run(() => setQuery(query)),
      leading: Icon(Icons.search_outlined, color: ThemeColors.textDisabled),
      hintText: t.common.search,
      hintStyle: WidgetStatePropertyAll(const TextStyle(color: ThemeColors.textDisabled)),
      trailing: query.isNotEmpty
          ? [IconButton(onPressed: () => setQuery(''), icon: Icon(Icons.clear, color: ThemeColors.textDisabled))]
          : [],
      backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
      padding: WidgetStatePropertyAll(EdgeInsets.only(left: 8)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ThemeColors.textDisabled),
        ),
      ),
      elevation: WidgetStatePropertyAll(0),
    );
  }
}
