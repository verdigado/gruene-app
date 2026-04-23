import 'package:flutter/material.dart';

class TextListItem extends StatelessWidget {
  final void Function() onPress;
  final String title;
  final bool isExternal;
  final Widget? trailing;

  const TextListItem({super.key, required this.onPress, required this.title, this.isExternal = false, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        onTap: onPress,
        title: Text(title, style: theme.textTheme.bodyLarge),
        trailing: SizedBox(
          height: 24,
          width: 24,
          child:
              trailing ??
              Icon(isExternal ? Icons.arrow_outward : Icons.chevron_right_outlined, color: theme.disabledColor),
        ),
        tileColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }
}
