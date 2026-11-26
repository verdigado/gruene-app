import 'package:flutter/material.dart';

class DialogButtonContainer extends StatelessWidget {
  final Widget child;
  final Alignment alignment;

  const DialogButtonContainer({super.key, required this.child, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: alignment,
      padding: EdgeInsets.all(8),
      width: 64,
      height: 64,
      child: CircleAvatar(
        foregroundColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surface,
        child: child,
      ),
    );
  }
}

class DialogCloseButton extends StatelessWidget {
  final void Function()? onClose;

  const DialogCloseButton({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return DialogButtonContainer(
      alignment: Alignment.topRight,
      child: CloseButton(onPressed: onClose ?? Navigator.of(context).maybePop),
    );
  }
}
