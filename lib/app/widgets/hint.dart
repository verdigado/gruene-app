import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class Hint extends StatelessWidget {
  final String text;

  const Hint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      spacing: 8,
      children: [
        Icon(Icons.info_outline, size: 16, color: ThemeColors.textDisabled),
        Flexible(
          child: Text(text, style: theme.textTheme.labelMedium?.copyWith(color: ThemeColors.textDisabled)),
        ),
      ],
    );
  }
}
