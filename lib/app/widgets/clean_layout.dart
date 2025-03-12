import 'package:flutter/material.dart';

class CleanLayout extends StatelessWidget {
  final Widget? child;
  final bool showAppBar;

  const CleanLayout({super.key, this.child, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: theme.colorScheme.surface, toolbarHeight: showAppBar ? null : 0),
      body: SafeArea(child: Container(color: theme.colorScheme.surface, child: child)),
    );
  }
}
