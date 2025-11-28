import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(bottom: 6, left: 24, right: 24),
      color: theme.colorScheme.surfaceDim,
      child: Text(title, style: theme.textTheme.titleMedium),
    );
  }
}
