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
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_expired.dart';
import 'package:gruene_app/prototype/flows/guest/guest_flow.dart';
import 'package:gruene_app/prototype/flows/guest/guest_own_access.dart';
import 'package:gruene_app/prototype/flows/guest/members_teaser.dart';
import 'package:gruene_app/prototype/prototype.dart';
import 'package:gruene_app/prototype/settings.dart';

/// PROTOTYPE: sections a guest may not use in this concept, by
/// bottom-navigation index. Wahlkampf (2) stays open, as does 2FA (4) — guests
/// need it to sign in. Tools (5) gets the teaser too; settings stay reachable
/// through the gear in the app bar. Mitglieder (3) is not locked but replaced,
/// see below. Adjust here, nowhere else.
const _lockedSectionsForGuests = <int, (String, String, TeaserSkeleton)>{
  0: ('News', 'Artikel', TeaserSkeleton.articles),
  1: ('Events', 'Termine', TeaserSkeleton.events),
  5: ('Tools', 'Die Grünen Tools', TeaserSkeleton.tools),
};

/// PROTOTYPE: the Mitglieder tab for guests. Not a 1/0 area: the member search
/// stays closed, the guest's own profile (picture, access, giving the account
/// back) is theirs.
const _membersTab = 3;

GoRouter createAppRouter(BuildContext context, GlobalKey<NavigatorState> navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.news.path,
    routes: [
      Routes.login,
      Routes.mfaLogin,
      Routes.settings,
      Routes.challengeDetail,
      StatefulShellRoute.indexedStack(
        builder: (context, _, navigationShell) {
          final theme = Theme.of(context);
          Future.delayed(Duration.zero, () {
            if (context.mounted) GetIt.I<ProfileFeatureChecker>().check(context);
          });

          // PROTOTYPE: an expired guest gets a screen that says so, instead of
          // the generic login failure they would otherwise land on. Replaces
          // the whole shell, bottom bar included — there is nothing left to
          // navigate to.
          //
          // Inside the listener rather than above it: switching persona does
          // not necessarily rebuild the shell on its own, and mid-demo the
          // change has to land without a restart.
          return PrototypeListener(
            builder: (context, child) {
              final expired =
                  guestOffboarding.isOn && prototypePersona.value.isGuest && ownAccess()?.status == GuestStatus.expired;
              return expired ? const GuestExpiredScreen() : child!;
            },
            child: _shell(context, theme, navigationShell),
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

/// The normal app shell. Extracted only so the prototype can put an expired
/// guest in front of it without indenting the whole thing.
Widget _shell(BuildContext context, ThemeData theme, StatefulNavigationShell navigationShell) {
  return Scaffold(
    appBar: AppBar(backgroundColor: theme.colorScheme.primary, toolbarHeight: 0),
    // The tab stays tappable and the bar stays complete — a guest sees
    // that the section exists and what it holds, just not its contents.
    body: SafeArea(
      child: PrototypeListener(
        builder: (context, child) {
          final asGuest = guestLockedSections.isOn && prototypePersona.value.isGuest;
          if (asGuest && navigationShell.currentIndex == _membersTab) return const GuestOwnAccessScreen();
          final locked = asGuest ? _lockedSectionsForGuests[navigationShell.currentIndex] : null;
          if (locked == null) return child!;
          return MembersTeaser(title: locked.$1, section: locked.$2, skeleton: locked.$3);
        },
        child: navigationShell,
      ),
    ),
    bottomNavigationBar: BottomNavigation(navigationShell: navigationShell),
  );
}
