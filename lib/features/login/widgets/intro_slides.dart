import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class IntroSlides extends StatelessWidget {
  const IntroSlides({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.login.discover, style: theme.textTheme.titleLarge),
        Text(t.login.discoverDescription, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
