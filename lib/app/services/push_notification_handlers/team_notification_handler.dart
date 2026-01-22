part of 'notification_handlers.dart';

class TeamNotificationHandler extends BaseNotificationHandler {
  @override
  void processMessage(RemoteMessage message, BuildContext? context) {
    var routerLocation = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignTeamDetail]);
    _navigateTo(context, routerLocation);
  }

  @override
  String? getPayload(RemoteMessage message) {
    return 'team';
  }

  @override
  void processPayload(NotificationResponse response, BuildContext? context) {
    _navigateTo(context, RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignTeamDetail]));
  }
}
