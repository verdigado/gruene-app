import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const FilterSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: title),
        Container(color: theme.colorScheme.surface, padding: screenPaddingSymmetric(vertical: 8), child: child),
      ],
    );
  }
}

class FilterDialog extends StatelessWidget {
  final void Function() resetFilters;
  final bool modified;
  final List<Widget> children;

  const FilterDialog({super.key, required this.resetFilters, required this.modified, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FullScreenDialog(
      appBarAction: modified
          ? TextButton(
              onPressed: resetFilters,
              child: Text(t.common.actions.resetFilter, style: theme.textTheme.bodyLarge),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          ...children,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: FilledButton(
              onPressed: Navigator.of(context).pop,
              style: ButtonStyle(minimumSize: WidgetStateProperty.all(Size.fromHeight(48))),
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
