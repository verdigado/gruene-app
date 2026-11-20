import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/utils/profile_feature_checker.dart';
import 'package:gruene_app/app/widgets/bottom_navigation.dart';
import 'package:gruene_app/features/guests/utils/guest_invitation_link.dart';

GoRouter createAppRouter(GlobalKey<NavigatorState> navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.news.path,
    routes: [
      Routes.login,
      Routes.mfaLogin,
      Routes.guestOnboarding,
      Routes.settings,
      Routes.challengeDetail,
      StatefulShellRoute.indexedStack(
        builder: (context, _, navigationShell) {
          final theme = Theme.of(context);
          Future.delayed(Duration.zero, () {
            if (context.mounted) GetIt.I<ProfileFeatureChecker>().check(context);
          });

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
      final currentPath = state.uri.path;
      final isLoginOpen = currentPath.startsWith(Routes.login.path);
      final isPublicRouteOpen = Routes.public.any((route) => currentPath.startsWith(route.path));

      final authBloc = context.read<AuthBloc>();
      final isLoggedIn = authBloc.state is Authenticated;
      final isLoggedOut = authBloc.state is Unauthenticated;

      if (isInvitationLink(state.uri)) {
        WidgetsBinding.instance
          ..addPostFrameCallback((_) => openInvitationLink(navigatorKey, invitationToken(state.uri)))
          ..ensureVisualUpdate();
        return isLoggedIn ? Routes.news.path : Routes.login.path;
      }

      if (isLoggedOut && !isPublicRouteOpen) {
        return Routes.login.path;
      }

      if (isLoggedIn && isLoginOpen) {
        return Routes.news.path;
      }
      return null;
    },
  );
}
