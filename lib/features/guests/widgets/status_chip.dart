import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label, style: theme.textTheme.labelSmall?.apply(color: color)),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      visualDensity: VisualDensity(vertical: -4),
      backgroundColor: theme.colorScheme.surface,
      shape: StadiumBorder(),
      side: BorderSide(color: color),
    );
  }
}
