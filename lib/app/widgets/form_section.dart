import 'package:flutter/material.dart';

class FormSection extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final double spacing;

  const FormSection({super.key, required this.children, this.title, this.spacing = 16});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        if (title != null) Text(title, style: theme.textTheme.titleMedium),
        ...children,
      ],
    );
  }
}
