import 'package:flutter/material.dart';

class ItemAction<T> {
  final IconData icon;
  final String label;
  final Color? color;
  final bool primary;
  final void Function(void Function(T) onSuccess) run;

  ItemAction({required this.icon, required this.label, this.color, required this.run, this.primary = false})
    : assert(primary == false || color == null);
}

Future<void> showActions<T>({
  required BuildContext context,
  required List<ItemAction<T>> actions,
  required void Function(T) onSuccess,
}) async {
  final action = await showModalBottomSheet<ItemAction<T>>(
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
    action.run(onSuccess);
  }
}
