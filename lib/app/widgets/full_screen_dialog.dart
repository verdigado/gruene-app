import 'package:flutter/material.dart';

class FullScreenDialog extends StatelessWidget {
  final Widget child;
  final List<Widget>? appBarActions;

  const FullScreenDialog({super.key, required this.child, this.appBarActions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceDim,
        surfaceTintColor: theme.colorScheme.surfaceDim,
        leading: IconButton(icon: Icon(Icons.close), onPressed: Navigator.of(context).pop),
        actions: appBarActions,
      ),
      body: SafeArea(child: child),
    );
  }
}

Future<T?> showFullScreenDialog<T extends Object?>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push(MaterialPageRoute<T>(fullscreenDialog: true, builder: builder));
