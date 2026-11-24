import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

Future<bool?> showAlertDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  String? confirmLabel,
}) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: content,
    actions: confirmLabel != null
        ? [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.common.actions.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ]
        : [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.common.actions.close))],
  ),
);

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required String label,
  void Function()? onConfirmed,
}) async {
  final confirmed = await showAlertDialog(context, title: title, content: content, confirmLabel: label);
  if (confirmed == true) onConfirmed?.call();
  return confirmed;
}
