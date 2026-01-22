import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/utils/build_page_without_animation.dart';
import 'package:gruene_app/features/campaigns/screens/campaigns_screen.dart';
import 'package:gruene_app/features/campaigns/screens/doors_screen.dart';
import 'package:gruene_app/features/campaigns/screens/flyer_screen.dart';
import 'package:gruene_app/features/campaigns/screens/posters_screen.dart';
import 'package:gruene_app/features/campaigns/screens/statistics_screen.dart';
import 'package:gruene_app/features/campaigns/screens/teams_screen.dart';
import 'package:gruene_app/features/events/screens/event_detail_screen.dart';
import 'package:gruene_app/features/events/screens/events_screen.dart';
import 'package:gruene_app/features/login/screens/login_screen.dart';
import 'package:gruene_app/features/mfa/screens/mfa_screen.dart';
import 'package:gruene_app/features/mfa/screens/token_input_screen.dart';
import 'package:gruene_app/features/mfa/screens/token_scan_screen.dart';
import 'package:gruene_app/features/news/screens/news_detail_screen.dart';
import 'package:gruene_app/features/news/screens/news_screen.dart';
import 'package:gruene_app/features/profiles/screens/digital_membership_card_screen.dart';
import 'package:gruene_app/features/profiles/screens/own_profile_screen.dart';
import 'package:gruene_app/features/settings/screens/push_notifications_screen.dart';
import 'package:gruene_app/features/settings/screens/settings_screen.dart';
import 'package:gruene_app/features/tools/screens/tools_screen.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

GoRoute buildRoute(String path, Widget child, {List<RouteBase>? routes, GoRouterRedirect? redirect}) => GoRoute(
  path: path,
  pageBuilder: (context, state) => buildPageWithoutAnimation(context: context, state: state, child: child),
  routes: routes ?? [],
  redirect: redirect,
);

class Routes {
  static GoRoute newsDetail = GoRoute(
    path: ':newsId',
    pageBuilder: (context, state) => buildPageWithoutAnimation(
      context: context,
      state: state,
      child: NewsDetailScreen(newsId: state.pathParameters['newsId']!),
    ),
  );
  static GoRoute news = buildRoute(
    RouteLocations.getRoute([RouteLocations.news]),
    NewsScreenContainer(),
    routes: [newsDetail],
  );
  static GoRoute eventDetail = GoRoute(
    path: ':eventId',
    pageBuilder: (context, state) {
      final extra = state.extra as ({DateTime recurrence, Calendar calendar});
      return buildPageWithoutAnimation(
        context: context,
        state: state,
        child: EventDetailScreenContainer(
          eventId: state.pathParameters['eventId']!,
          calendar: extra.calendar,
          recurrence: extra.recurrence,
        ),
      );
    },
  );
  static GoRoute events = buildRoute(
    RouteLocations.getRoute([RouteLocations.events]),
    EventsScreenContainer(),
    routes: [eventDetail],
  );

  static GoRoute campaignDoorDetail = buildRoute(RouteLocations.campaignDoorDetail, DoorsScreen());
  static GoRoute campaignPosterDetail = buildRoute(RouteLocations.campaignPosterDetail, PostersScreen());
  static GoRoute campaignFlyerDetail = buildRoute(RouteLocations.campaignFlyerDetail, FlyerScreen());
  static GoRoute campaignTeamDetail = buildRoute(RouteLocations.campaignTeamDetail, TeamsScreen());
  static GoRoute campaignStatisticsDetail = buildRoute(RouteLocations.campaignStatisticsDetail, StatisticsScreen());
  // static GoRoute campaigns = buildRoute('/campaigns', CampaignsScreen());
  static StatefulShellRoute campaignShellRoute = StatefulShellRoute(
    // builder: (context, _, navigationShell) {
    //   return CampaignsScreen(navigationShell: navigationShell);
    // },
    builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
      return navigationShell;
    },
    navigatorContainerBuilder: (BuildContext context, StatefulNavigationShell navigationShell, List<Widget> children) {
      return CampaignsScreen(navigationShell: navigationShell, children: children);
    },
    branches: [
      StatefulShellBranch(preload: true, routes: [campaignDoorDetail]),
      StatefulShellBranch(preload: true, routes: [campaignPosterDetail]),
      StatefulShellBranch(preload: true, routes: [campaignFlyerDetail]),
      StatefulShellBranch(preload: true, routes: [campaignTeamDetail]),
      StatefulShellBranch(preload: true, routes: [campaignStatisticsDetail]),
    ],
  );
  static GoRoute campaigns = GoRoute(
    path: RouteLocations.getRoute([RouteLocations.campaigns]),
    routes: [campaignShellRoute],
    redirect: (_, state) {
      if (state.fullPath == RouteLocations.getRoute([RouteLocations.campaigns])) {
        return RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignDoorDetail]);
      }
      return null;
    },
  );
  static GoRoute digitalMembershipCard = buildRoute(
    RouteLocations.digitalMembershipCard,
    DigitalMembershipCardScreen(),
  );
  static GoRoute profiles = buildRoute(
    RouteLocations.getRoute([RouteLocations.profiles]),
    OwnProfileScreen(),
    routes: [digitalMembershipCard],
  );
  static GoRoute mfaTokenInput = buildRoute(RouteLocations.tokenInput, TokenInputScreen());
  static GoRoute mfaTokenScan = buildRoute(RouteLocations.tokenScan, TokenScanScreen(), routes: [mfaTokenInput]);
  static GoRoute mfa = buildRoute(RouteLocations.getRoute([RouteLocations.mfa]), MfaScreen(), routes: [mfaTokenScan]);
  static GoRoute tools = buildRoute(RouteLocations.getRoute([RouteLocations.tools]), ToolsScreen());
  static GoRoute mfaLogin = buildRoute(
    RouteLocations.getRoute([RouteLocations.mfaLogin]),
    MfaScreen(),
    routes: [mfaTokenScan, mfaTokenInput],
  );
  static GoRoute login = buildRoute(RouteLocations.getRoute([RouteLocations.login]), LoginScreen());
  static GoRoute pushNotifications = buildRoute(RouteLocations.pushNotifications, PushNotificationsScreen());
  static GoRoute settings = buildRoute(
    RouteLocations.getRoute([RouteLocations.settings]),
    SettingsScreen(),
    routes: [pushNotifications],
  );
}
