import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';

class SelectionListItem extends StatelessWidget {
  final void Function() toggleSelection;
  final String title;
  final bool selected;

  const SelectionListItem({super.key, required this.title, required this.toggleSelection, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextListItem(
      onPress: toggleSelection,
      title: title,
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? theme.colorScheme.secondary : theme.colorScheme.surface,
          border: Border.all(width: 2, color: selected ? theme.colorScheme.secondary : ThemeColors.textDisabled),
        ),
        child: Checkbox(
          value: selected,
          checkColor: theme.colorScheme.surface,
          activeColor: theme.colorScheme.secondary,
          onChanged: (_) => toggleSelection(),
          shape: CircleBorder(),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
