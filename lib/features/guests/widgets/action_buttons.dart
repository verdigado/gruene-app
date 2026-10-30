import 'package:flutter/material.dart' hide Action;
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';

class ActionButtons<T> extends StatelessWidget {
  final List<Action<T>> actions;
  final void Function(T) onSuccess;

  const ActionButtons({super.key, required this.actions, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: horizontalScreenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: actions.map((action) {
          final color = action.color;
          return action.primary
              ? FilledButton.icon(
                  label: Text(action.label),
                  icon: Icon(action.icon),
                  onPressed: () => action.action(onSuccess),
                )
              : OutlinedButton.icon(
                  label: Text(action.label),
                  icon: Icon(action.icon),
                  onPressed: () => action.action(onSuccess),
                  style: color != null
                      ? OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color),
                        )
                      : null,
                );
        }).toList(),
      ),
    );
  }
}
