import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/error_message.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class ErrorScreen<T> extends StatelessWidget {
  final Object? error;
  final String? errorMessage;
  final IconData? icon;
  final T Function() retry;

  const ErrorScreen({super.key, required this.retry, this.error, this.errorMessage, this.icon})
    : assert((error == null) != (errorMessage == null) && error is! String);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Icon(icon, color: ThemeColors.grey200, size: 48),
          Text(errorMessage ?? getErrorMessage(error!), textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          TextButton(
            onPressed: retry,
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(ThemeColors.text),
              textStyle: WidgetStatePropertyAll(
                theme.textTheme.labelLarge!.apply(decoration: TextDecoration.underline),
              ),
            ),
            child: Text(t.error.retry),
          ),
        ],
      ),
    );
  }
}
