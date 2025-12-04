import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';

class SelectionListItem extends StatelessWidget {
  final void Function() toggleSelection;
  final String title;
  final bool selected;
  final Color? backgroundColor;

  const SelectionListItem({
    super.key,
    required this.title,
    required this.toggleSelection,
    required this.selected,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = backgroundColor ?? theme.colorScheme.surface;
    return Container(
      color: backgroundColor,
      child: TextListItem(
        onPress: toggleSelection,
        title: title,
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? theme.colorScheme.secondary : surfaceColor,
            border: Border.all(width: 2, color: selected ? theme.colorScheme.secondary : ThemeColors.textDisabled),
          ),
          child: Checkbox(
            value: selected,
            checkColor: surfaceColor,
            activeColor: theme.colorScheme.secondary,
            onChanged: (_) => toggleSelection(),
            shape: CircleBorder(),
            side: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
