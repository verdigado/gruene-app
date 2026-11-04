import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/widgets/clean_layout.dart';

class OnboardingMessage extends StatelessWidget {
  final String title;
  final String hint;
  final String action;
  final void Function() onAction;

  const OnboardingMessage({
    super.key,
    required this.title,
    required this.hint,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CleanLayout(
      showAppBar: false,
      child: Padding(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            Text(hint, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            FilledButton(onPressed: onAction, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
