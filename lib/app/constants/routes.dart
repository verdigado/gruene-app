import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/utils/build_page_without_animation.dart';
import 'package:gruene_app/features/campaigns/screens/campaigns_screen.dart';
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

GoRoute buildRoute(String path, Widget child, {List<RouteBase>? routes}) => GoRoute(
      path: path,
      pageBuilder: (context, state) => buildPageWithoutAnimation(context: context, state: state, child: child),
      routes: routes ?? [],
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
  static GoRoute news = buildRoute('/news', NewsScreenContainer(), routes: [newsDetail]);
  static GoRoute campaigns = buildRoute('/campaigns', CampaignsScreen());
  static GoRoute digitalMembershipCard = buildRoute('digital-membership-card', DigitalMembershipCardScreen());
  static GoRoute profiles = buildRoute('/profiles', OwnProfileScreen(), routes: [digitalMembershipCard]);
  static GoRoute mfaTokenInput = buildRoute('token-input', TokenInputScreen());
  static GoRoute mfaTokenScan = buildRoute('token-scan', TokenScanScreen(), routes: [mfaTokenInput]);
  static GoRoute mfa = buildRoute('/mfa', MfaScreen(), routes: [mfaTokenScan]);
  static GoRoute tools = buildRoute('/tools', ToolsScreen());
  static GoRoute mfaLogin = buildRoute('/mfa-login', MfaScreen(), routes: [mfaTokenScan, mfaTokenInput]);
  static GoRoute login = buildRoute('/login', LoginScreen());
  static GoRoute pushNotifications = buildRoute('push-notifications', PushNotificationsScreen());
  static GoRoute settings = buildRoute('/settings', SettingsScreen(), routes: [pushNotifications]);
}
