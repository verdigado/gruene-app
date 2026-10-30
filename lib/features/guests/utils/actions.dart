import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class Action<T> {
  final IconData icon;
  final String label;
  final Color? color;
  final bool primary;
  final void Function(void Function(T) onSuccess) action;

  Action({required this.icon, required this.label, this.color, required this.action, this.primary = false})
    : assert(primary == false || color == null);
}

Future<void> showActions<T>({
  required BuildContext context,
  required List<Action<T>> actions,
  required void Function(T) onSuccess,
}) async {
  final action = await showModalBottomSheet<Action<T>>(
    context: context,
    showDragHandle: true,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map(
              (action) => ListTile(
                leading: Icon(action.icon, color: action.color),
                title: Text(action.label),
                onTap: () => Navigator.of(context).pop(action),
              ),
            )
            .toList(),
      ),
    ),
  );
  if (action != null) {
    action.action(onSuccess);
  }
}

Future<bool?> showConfirmationDialog({required BuildContext context, required String title, required String content}) =>
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.common.actions.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.actions.confirm, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
