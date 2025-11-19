import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/widgets/bottom_navigation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createAppRouter(BuildContext context, GlobalKey<NavigatorState> navigatorKey) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.events.path,
    routes: [
      Routes.login,
      Routes.mfaLogin,
      Routes.settings,
      StatefulShellRoute.indexedStack(
        builder: (context, _, navigationShell) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(backgroundColor: theme.colorScheme.primary, toolbarHeight: 0),
            body: SafeArea(child: navigationShell),
            bottomNavigationBar: BottomNavigation(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(routes: [Routes.news]),
          StatefulShellBranch(routes: [Routes.events]),
          StatefulShellBranch(routes: [Routes.campaigns]),
          StatefulShellBranch(routes: [Routes.profiles]),
          StatefulShellBranch(routes: [Routes.mfa]),
          StatefulShellBranch(routes: [Routes.tools]),
        ],
      ),
    ],
    redirect: (context, state) {
      final currentPath = state.uri.toString();
      final isLoginOpen = currentPath.startsWith(Routes.login.path);
      final isMfaOpen = currentPath.startsWith(Routes.mfa.path);

      final authBloc = context.read<AuthBloc>();
      final isLoggedIn = authBloc.state is Authenticated;
      final isLoggedOut = authBloc.state is Unauthenticated;

      if (isLoggedOut && !isMfaOpen) {
        return Routes.login.path;
      }

      if (isLoggedIn && isLoginOpen) {
        return Routes.news.path;
      }

      return null;
    },
  );
}
