import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/widgets/custom_app_bar.dart';

class ContentPage extends StatelessWidget {
  final String title;
  final Widget child;

  final Color? contentBackgroundColor;

  final Alignment alignment;

  const ContentPage({
    super.key,
    required this.title,
    required this.child,
    this.contentBackgroundColor,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: contentBackgroundColor ?? theme.colorScheme.secondary,
      body: Align(
        alignment: alignment,
        child: SingleChildScrollView(child: child),
      ),
      appBar: CustomAppBar(
        title: title,
      ),
    );
  }
}
