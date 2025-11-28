import 'package:flutter/material.dart';

class DialogCloseButton extends StatelessWidget {
  const DialogCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.topRight,
      padding: EdgeInsets.all(8),
      width: double.infinity,
      height: 64,
      child: CircleAvatar(
        backgroundColor: theme.colorScheme.surface,
        child: IconButton(
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
