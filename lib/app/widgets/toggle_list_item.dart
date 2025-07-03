import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class ToggleListItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleListItem({super.key, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text(title, style: theme.textTheme.bodyLarge?.apply(color: ThemeColors.text)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: onChanged != null ? theme.colorScheme.primary : ThemeColors.textDisabled,
        ),
      ),
    );
  }
}
