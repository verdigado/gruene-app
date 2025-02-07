import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/utils.dart';

class ExpansionListTile extends StatelessWidget {
  final List<Widget> children;
  final String title;

  const ExpansionListTile({super.key, required this.children, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        shape: const Border(),
        title: Text(title),
        tilePadding: const EdgeInsets.all(0),
        backgroundColor: theme.colorScheme.surface,
        collapsedBackgroundColor: theme.colorScheme.surface,
        children: children.withDividers(),
      ),
    );
  }
}
