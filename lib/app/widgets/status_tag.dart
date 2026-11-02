import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class StatusTag extends StatelessWidget {
  final String label;
  final Color color;

  const StatusTag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(ThemeColors.tintedBackgroundAlpha),
        border: Border.all(color: color.withAlpha(ThemeColors.tintedBorderAlpha)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: theme.textTheme.labelSmall?.apply(color: color)),
    );
  }
}
