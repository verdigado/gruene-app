import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/error_message.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class ErrorScreen<T> extends StatelessWidget {
  final Object? error;
  final String? errorMessage;
  final T Function() retry;

  const ErrorScreen({super.key, required this.retry, this.error, this.errorMessage})
      : assert((error == null) != (errorMessage == null));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage ?? getErrorMessage(error!),
            textAlign: TextAlign.center,
            style: TextStyle(color: ThemeColors.textWarning),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: retry,
            child: Text(t.error.retry),
          ),
        ],
      ),
    );
  }
}
