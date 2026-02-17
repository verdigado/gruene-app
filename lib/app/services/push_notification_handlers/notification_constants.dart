part of 'notification_handlers.dart';

class NotificationConstants {
  static const String payloadTeamTop10 = 'teamTop10';
  static const String payloadTeam = 'team';
  static const String payloadNewsPrefix = 'news.';

  static const notificationTypeNews = 'news.published';
  static const notificationTypeTeamMembershipUpdated = 'campaigns.teamMembership.updated';
  static const notificationTypeTeamTop10Updated = 'campaigns.team-top10.updated';
  static const notificationTypeRouteAssignmentUpdated = 'campaigns.routeAssignment.updated';
  static const notificationTypeAreaAssignmentUpdated = 'campaigns.areaAssignment.updated';
}
