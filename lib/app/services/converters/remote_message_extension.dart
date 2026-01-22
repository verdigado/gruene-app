part of '../converters.dart';

extension RemoteMessageExtension on RemoteMessage? {
  NotificationMessageType? getMessageType() {
    if (this == null) return null;
    var type = this?.data['type'];

    switch (type) {
      case 'news.published':
        return NotificationMessageType.news;
      case 'campaigns.teamMembership.updated':
        return NotificationMessageType.teamMembershipUpdate;
      case 'campaigns.routeAssignment.updated':
        return NotificationMessageType.routeAssignmentUpdate;
      case 'campaigns.areaAssignment.updated':
        return NotificationMessageType.areaAssignmentUpdate;
    }
    return null;
  }

  BaseNotificationHandler getNotificationHandler() {
    final type = getMessageType();
    return GetIt.I<BaseNotificationHandler>(instanceName: type?.toString() ?? '');
  }
}

extension NotificationResponseExtension on NotificationResponse {
  BaseNotificationHandler getNotificationHandler() {
    var localPayload = payload;
    NotificationMessageType? instanceIdentifier;
    if (localPayload == null) throw UnimplementedError();
    if (localPayload.startsWith('news.')) {
      instanceIdentifier = NotificationMessageType.news;
    } else if (localPayload == 'team') {
      instanceIdentifier = NotificationMessageType.teamMembershipUpdate;
    }

    return GetIt.I<BaseNotificationHandler>(instanceName: instanceIdentifier.toString());
  }
}
