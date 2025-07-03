import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(title, style: theme.textTheme.displayMedium?.apply(color: theme.colorScheme.surface)),
      leading: BackButton(),
      foregroundColor: theme.colorScheme.surface,
      backgroundColor: theme.primaryColor,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: theme.colorScheme.surface),
          onPressed: () => context.push(Routes.settings.path),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
