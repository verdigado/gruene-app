import 'package:flutter/material.dart';

class ProfileBoxItem extends StatelessWidget {
  final String title;
  final void Function()? onPress;

  const ProfileBoxItem({
    super.key,
    required this.title,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      onTap: onPress,
      trailing: onPress != null ? Icon(Icons.open_in_browser_outlined, color: theme.primaryColor) : null,
    );
  }
}
