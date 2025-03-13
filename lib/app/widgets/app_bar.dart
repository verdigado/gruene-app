import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/theme/theme.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? appBarAction;
  final PreferredSizeWidget? tabBar;
  final String title;

  const MainAppBar({super.key, required this.title, this.appBarAction, this.tabBar});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context);
    final authBloc = context.read<AuthBloc>();
    final isLoggedIn = authBloc.state is Authenticated;
    final theme = Theme.of(context);
    final foregroundColor = isLoggedIn ? theme.colorScheme.surface : ThemeColors.text;
    return AppBar(
      title: Text(title, style: theme.textTheme.displayMedium?.apply(color: foregroundColor)),
      foregroundColor: foregroundColor,
      backgroundColor: isLoggedIn ? theme.primaryColor : theme.colorScheme.surfaceDim,
      centerTitle: true,
      bottom: tabBar,
      actions: [
        if (appBarAction != null) appBarAction!,
        if (currentRoute.path != Routes.settings.path && isLoggedIn)
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.colorScheme.surface),
            onPressed: () => context.push(Routes.settings.path),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (tabBar == null ? 0 : kTextTabBarHeight));
}
