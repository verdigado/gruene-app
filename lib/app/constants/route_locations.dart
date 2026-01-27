class RouteLocations {
  static const String campaigns = 'campaigns';
  static const String profiles = 'profiles';
  static const String news = 'news';
  static const String mfa = 'mfa';
  static const String events = 'events';
  static const String tools = 'tools';
  static const String mfaLogin = 'mfa-login';
  static const String login = 'login';
  static const String settings = 'settings';

  static const String tokenInput = 'token-input';
  static const String tokenScan = 'token-scan';
  static const String pushNotifications = 'push-notifications';
  static const String digitalMembershipCard = 'digital-membership-card';

  static const String campaignDoorDetail = 'door';
  static const String campaignPosterDetail = 'poster';
  static const String campaignFlyerDetail = 'flyer';
  static const String campaignTeamDetail = 'team';
  static const String campaignStatisticsDetail = 'statistics';

  static String getRoute(Iterable<String> locations) {
    return '/${locations.join('/')}';
  }
}
