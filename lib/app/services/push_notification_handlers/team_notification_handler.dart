part of 'notification_handlers.dart';

class TeamNotificationHandler extends BaseNotificationHandler {
  @override
  void processMessage(RemoteMessage message, BuildContext? context) {
    var routerLocation = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignTeamDetail]);
    _navigateTo(context, routerLocation);
    GetIt.I<TeamRefreshController>().reload();
  }

  @override
  String? getPayload(RemoteMessage message) {
    return NotificationConstants.payloadTeam;
  }

  @override
  void processPayload(NotificationResponse response, BuildContext? context) {
    _navigateTo(context, RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignTeamDetail]));
    GetIt.I<TeamRefreshController>().reload();
  }
}
