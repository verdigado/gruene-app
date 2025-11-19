import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';

class ExpansionListTile extends StatelessWidget {
  final List<Widget> children;
  final String? titleText;
  final Widget? title;
  final EdgeInsetsGeometry titlePadding;
  final Color? backgroundColor;
  final Widget? icon;
  final Color? iconColor;

  const ExpansionListTile({
    super.key,
    required this.children,
    this.titleText,
    this.title,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.backgroundColor,
    this.icon,
    this.iconColor,
  }) : assert(titleText != null || title != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        shape: const Border(),
        title: title ?? Text(titleText!),
        tilePadding: titlePadding,
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        collapsedBackgroundColor: backgroundColor ?? theme.colorScheme.surface,
        trailing: icon,
        iconColor: iconColor ?? ThemeColors.textDisabled,
        collapsedIconColor: iconColor ?? ThemeColors.textDisabled,
        children: children.withDividers(),
      ),
    );
  }
}
