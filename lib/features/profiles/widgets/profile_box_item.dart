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
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            if (onPress != null)
              Icon(
                Icons.open_in_browser_outlined,
                color: theme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
