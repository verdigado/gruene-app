import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';

class ExpansionListTile extends StatelessWidget {
  final Iterable<Widget> children;
  final String? titleText;
  final Widget? title;
  final EdgeInsetsGeometry titlePadding;
  final String? emptyText;
  final Color? backgroundColor;
  final Widget? icon;
  final Color? iconColor;
  final bool initiallyExpanded;

  const ExpansionListTile({
    super.key,
    required this.children,
    this.titleText,
    this.title,
    this.titlePadding = horizontalScreenPadding,
    this.emptyText,
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.initiallyExpanded = false,
  }) : assert(titleText != null || title != null);

  @override
  Widget build(BuildContext context) {
    final emptyText = this.emptyText;
    final theme = Theme.of(context);
    final showEmptyText = emptyText != null && children.isEmpty;

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
        initiallyExpanded: initiallyExpanded,
        expandedAlignment: Alignment.centerLeft,
        children: showEmptyText ? [Padding(
          padding: screenPaddingSymmetric(vertical: 8),
          child: Text(emptyText),
        )] : children.withDividers(),
      ),
    );
  }
}
