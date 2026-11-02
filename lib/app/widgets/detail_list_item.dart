import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';

class DetailListItem extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? tag;
  final bool _isHeader;

  const DetailListItem({super.key, required this.title, required this.child, this.tag}) : _isHeader = false;

  const DetailListItem.header({super.key, required this.title, required this.child, this.tag}) : _isHeader = true;

  @override
  Widget build(BuildContext context) {
    final tag = this.tag;
    final theme = Theme.of(context);
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tag != null) Align(alignment: Alignment.centerRight, child: tag),
          Text(title, style: _isHeader ? theme.textTheme.titleLarge : theme.textTheme.titleMedium),
        ],
      ),
      subtitle: Padding(padding: const EdgeInsets.only(top: 12), child: child),
      tileColor: theme.colorScheme.surface,
      contentPadding: _isHeader ? screenPadding.copyWith(bottom: 16) : null,
    );
  }
}
