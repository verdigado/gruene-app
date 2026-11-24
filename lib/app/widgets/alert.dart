import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

Future<bool?> showAlertDialog(BuildContext context, {required String title, required String content, Widget? action}) =>
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: action != null
            ? [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.common.actions.cancel)),
                action,
              ]
            : [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.common.actions.close))],
      ),
    );

Future<bool?> showConfirmationDialog(BuildContext context, {required String title, required String content}) =>
    showAlertDialog(
      context,
      title: title,
      content: content,
      action: TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(t.common.actions.confirm, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
    );
