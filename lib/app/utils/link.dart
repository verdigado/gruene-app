import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/open_url.dart';

TextSpan inlineLink(BuildContext context, {required String text, required String url}) {
  final theme = Theme.of(context);
  return TextSpan(
    text: text,
    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
    recognizer: TapGestureRecognizer()..onTap = () => openUrl(url, context),
  );
}
