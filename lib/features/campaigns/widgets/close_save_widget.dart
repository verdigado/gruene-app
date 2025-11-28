import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CloseSaveWidget extends StatelessWidget {
  final void Function()? onSave;
  final void Function() onClose;

  const CloseSaveWidget({super.key, this.onSave, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GestureDetector(onTap: onClose, child: Icon(Icons.close_outlined)),
        _getSaveAction(theme),
      ],
    );
  }

  Widget _getSaveAction(ThemeData theme) {
    if (onSave == null) return SizedBox.shrink();
    return Expanded(
      child: GestureDetector(
        onTap: onSave,
        child: Text(t.common.actions.save, textAlign: TextAlign.right, style: theme.textTheme.titleMedium),
      ),
    );
  }
}
