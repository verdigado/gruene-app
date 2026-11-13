import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class StepProgress extends StatelessWidget {
  final int current;
  final int total;

  const StepProgress({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          t.common.step(current: current, total: total),
          style: theme.textTheme.bodySmall,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: current / total, minHeight: 4, backgroundColor: ThemeColors.grey200),
        ),
      ],
    );
  }
}
