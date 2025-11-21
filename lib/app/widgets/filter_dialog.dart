import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class FilterDialog extends StatelessWidget {
  final void Function() resetFilters;
  final bool modified;
  final List<Widget> children;

  const FilterDialog({super.key, required this.resetFilters, required this.modified, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FullScreenDialog(
      appBarActions: modified
          ? [
              TextButton(
                onPressed: resetFilters,
                child: Text(t.common.actions.resetFilter, style: theme.textTheme.bodyLarge),
              ),
            ]
          : [],
      child: ListView(
        children: [
          ...children,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: FilledButton(
              onPressed: Navigator.of(context).pop,
              style: ButtonStyle(minimumSize: WidgetStateProperty.all(Size.fromHeight(56))),
              child: Text(
                t.common.actions.applyFilter,
                style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
