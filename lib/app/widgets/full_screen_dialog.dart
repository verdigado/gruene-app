import 'package:flutter/material.dart';

class FullScreenDialog extends StatelessWidget {
  final Widget child;
  final Widget? appBarAction;

  const FullScreenDialog({super.key, required this.child, this.appBarAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarAction = this.appBarAction;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceDim,
        surfaceTintColor: theme.colorScheme.surfaceDim,
        automaticallyImplyLeading: false,
        actions: [
          appBarAction != null
              ? Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: appBarAction),
                )
              : SizedBox.shrink(),
          IconButton(icon: Icon(Icons.close), onPressed: Navigator.of(context).pop),
        ],
      ),
      body: SafeArea(child: SingleChildScrollView(child: child)),
    );
  }
}

Future<T?> showFullScreenDialog<T extends Object?>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push(MaterialPageRoute<T>(fullscreenDialog: true, builder: builder));
