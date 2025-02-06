import 'package:flutter/material.dart';

class FullScreenDialog extends StatelessWidget {
  final Widget? child;

  const FullScreenDialog({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceDim,
        leading: IconButton(icon: Icon(Icons.close), onPressed: Navigator.of(context).pop),
      ),
      body: child,
    );
  }
}

void showFullScreenDialog(BuildContext context, WidgetBuilder builder) {
  Navigator.of(context).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: builder));
}
