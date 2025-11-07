import 'package:flutter/material.dart';

class MapBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final void Function() onClose;

  const MapBottomSheet({super.key, required this.child, required this.onClose, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: title == null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
              children: [
                if (title != null) Text(title!, style: theme.textTheme.bodyLarge),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}
