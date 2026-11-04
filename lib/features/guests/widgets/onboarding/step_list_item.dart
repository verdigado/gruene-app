import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/number_badge.dart';

class StepListItem extends StatelessWidget {
  final int number;
  final String title;
  final String hint;

  const StepListItem({super.key, required this.number, required this.title, required this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MergeSemantics(
      child: Row(
        spacing: 16,
        children: [
          NumberBadge(number: number),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(hint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
