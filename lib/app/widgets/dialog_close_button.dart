import 'package:flutter/material.dart';

class DialogCloseButton extends StatelessWidget {
  const DialogCloseButton({super.key, this.onClose});

  final void Function()? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.topRight,
      padding: EdgeInsets.all(8),
      width: 64,
      height: 64,
      child: CircleAvatar(
        backgroundColor: theme.colorScheme.surface,
        child: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
