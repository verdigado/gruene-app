import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';

class ExpansionListTile extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final EdgeInsetsGeometry titlePadding;
  final Color? backgroundColor;

  const ExpansionListTile({
    super.key,
    required this.children,
    required this.title,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        shape: const Border(),
        title: Text(title),
        tilePadding: titlePadding,
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        collapsedBackgroundColor: backgroundColor ?? theme.colorScheme.surface,
        iconColor: ThemeColors.textDisabled,
        collapsedIconColor: ThemeColors.textDisabled,
        children: children.withDividers(),
      ),
    );
  }
}
