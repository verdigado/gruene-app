import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class OnboardingLoginStep extends StatelessWidget {
  final String email;

  const OnboardingLoginStep({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Text(t.guests.onboarding.login.title, style: theme.textTheme.titleLarge),
        Text(t.guests.onboarding.login.hint),
      ],
    );
  }
}
