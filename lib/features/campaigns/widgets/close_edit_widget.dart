import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CloseEditWidget extends StatelessWidget {
  final void Function()? onEdit;
  final void Function() onClose;

  const CloseEditWidget({super.key, this.onEdit, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GestureDetector(onTap: onClose, child: Icon(Icons.close)),
        _getSaveAction(theme),
      ],
    );
  }

  Widget _getSaveAction(ThemeData theme) {
    if (onEdit == null) return SizedBox.shrink();
    return Expanded(
      child: GestureDetector(
        onTap: onEdit,
        child: Text(t.common.actions.edit, textAlign: TextAlign.right, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
