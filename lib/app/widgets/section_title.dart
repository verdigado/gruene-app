import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: screenPaddingSymmetric(vertical: 8),
      color: theme.colorScheme.surfaceDim,
      child: Text(title, style: theme.textTheme.titleMedium),
    );
  }
}
