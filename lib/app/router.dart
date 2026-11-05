// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/utils/profile_feature_checker.dart';
import 'package:gruene_app/app/widgets/bottom_navigation.dart';
import 'package:gruene_app/features/guests/utils/guest_onboarding.dart';

bool _startLinkUsed = false;

/// A new router is created on every auth change. Only the first one starts at the link the app was opened with,
/// otherwise every login or logout would return to that link.
GoRouter createAppRouter(BuildContext context, GlobalKey<NavigatorState> navigatorKey) {
  final ignoreStartLink = _startLinkUsed;
  _startLinkUsed = true;

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.news.path,
    overridePlatformDefaultLocation: ignoreStartLink,
    routes: [
      Routes.login,
      Routes.mfaLogin,
      Routes.guestInvitation,
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
      final currentPath = state.uri.toString();
      final isLoginOpen = currentPath.startsWith(Routes.login.path);
      final isMfaOpen = currentPath.startsWith(Routes.mfa.path);

      final authBloc = context.read<AuthBloc>();
      final isLoggedIn = authBloc.state is Authenticated;
      final isLoggedOut = authBloc.state is Unauthenticated;

      if (state.uri.path == Routes.guestInvitation.path) {
        if (!isInvitationHandled(invitationToken(state.uri))) return null;
        return isLoggedIn ? Routes.news.path : Routes.login.path;
      }

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
