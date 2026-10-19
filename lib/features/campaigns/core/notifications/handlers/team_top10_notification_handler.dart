part of '../campaign_notification_handlers.dart';

class TeamTop10NotificationHandler extends BaseNotificationHandler {
  @override
  void processMessage(RemoteMessage message, BuildContext? context) {
    var routerLocation = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignStatisticsDetail]);
    navigateTo(context, routerLocation);
  }

  @override
  String? getPayload(RemoteMessage message) {
    return NotificationConstants.payloadTeamTop10;
  }

  @override
  void processPayload(NotificationResponse response, BuildContext? context) {
    var routerLocation = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignStatisticsDetail]);
    navigateTo(context, routerLocation);
  }
}
