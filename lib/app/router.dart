import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';

GoRouter createAppRouter(BuildContext context, GlobalKey<NavigatorState> navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.news.path,
    routes: [
      Routes.news,
      Routes.campaigns,
      Routes.profiles,
      Routes.mfa,
      Routes.tools,
      Routes.settings,
      Routes.login,
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
