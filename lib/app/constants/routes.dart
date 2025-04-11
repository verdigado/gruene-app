import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/utils/build_page_without_animation.dart';
import 'package:gruene_app/app/widgets/main_layout.dart';
import 'package:gruene_app/features/campaigns/screens/campaigns_screen.dart';
import 'package:gruene_app/features/login/screens/login_screen.dart';
import 'package:gruene_app/features/mfa/screens/mfa_screen.dart';
import 'package:gruene_app/features/mfa/screens/token_input_screen.dart';
import 'package:gruene_app/features/mfa/screens/token_scan_screen.dart';
import 'package:gruene_app/features/news/screens/news_detail_screen.dart';
import 'package:gruene_app/features/news/screens/news_screen.dart';
import 'package:gruene_app/features/profiles/screens/own_profile_screen.dart';
import 'package:gruene_app/features/settings/screens/push_notifications_screen.dart';
import 'package:gruene_app/features/settings/screens/settings_screen.dart';
import 'package:gruene_app/features/settings/screens/support_screen.dart';
import 'package:gruene_app/features/tools/screens/tools_screen.dart';
import 'package:gruene_app/i18n/translations.g.dart';

GoRoute buildRoute(String path, String? name, Widget child, {List<RouteBase>? routes, bool withMainLayout = true}) {
  return GoRoute(
    name: name,
    path: path,
    pageBuilder: (BuildContext context, GoRouterState state) => buildPageWithoutAnimation<void>(
      context: context,
      state: state,
      child: withMainLayout ? MainLayout(child: child) : child,
    ),
    routes: routes ?? [],
  );
}

class Routes {
  static GoRoute newsDetail = GoRoute(
    name: t.news.newsDetail,
    path: ':newsId',
    pageBuilder: (BuildContext context, GoRouterState state) => buildPageWithoutAnimation<void>(
      context: context,
      state: state,
      child: MainLayout(child: NewsDetailScreen(newsId: state.pathParameters['newsId']!)),
    ),
  );
  static GoRoute news =
      buildRoute('/news', t.news.news, NewsScreenContainer(), routes: [newsDetail], withMainLayout: false);
  static GoRoute campaigns = buildRoute('/campaigns', t.campaigns.campaigns, CampaignsScreen());
  static GoRoute profiles = buildRoute('/profiles', t.profiles.profiles, OwnProfileScreen());
  static GoRoute mfaTokenScan = buildRoute('token-scan', t.mfa.tokenScan.title, TokenScanScreen());
  static GoRoute mfaTokenInput = buildRoute('token-input', t.mfa.tokenInput.title, TokenInputScreen());
  static GoRoute mfa = buildRoute('/mfa', t.mfa.mfa, MfaScreen(), routes: [mfaTokenScan, mfaTokenInput]);
  static GoRoute tools = buildRoute('/tools', t.tools.tools, ToolsScreen(), withMainLayout: false);
  static GoRoute login = buildRoute('/login', t.login.login, LoginScreen(), withMainLayout: false);
  static GoRoute support = buildRoute('support', t.settings.support.support, SupportScreen());
  static GoRoute pushNotifications =
      buildRoute('push-notifications', t.settings.pushNotifications.pushNotifications, PushNotificationsScreen());
  static GoRoute settings = buildRoute(
    '/settings',
    t.settings.settings,
    SettingsScreen(),
    routes: [pushNotifications, support],
  );
}
