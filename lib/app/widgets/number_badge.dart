import 'package:flutter/material.dart';

class NumberBadge extends StatelessWidget {
  final int number;

  const NumberBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
      child: Text('$number', style: theme.textTheme.displayMedium?.apply(color: theme.colorScheme.surface)),
    );
  }
}
