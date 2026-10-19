part of '../converters.dart';

extension NullableRemoteMessageHandling on RemoteMessage? {
  NotificationMessageType? getMessageType() {
    if (this == null) return null;
    var type = this?.data['type'];

    switch (type) {
      case NotificationConstants.notificationTypeNews:
        return NotificationMessageType.news;
      case NotificationConstants.notificationTypeMfa:
        return NotificationMessageType.mfa;
      case NotificationConstants.notificationTypeTeamMembershipUpdated:
        return NotificationMessageType.teamMembershipUpdate;
      case NotificationConstants.notificationTypeTeamTop10Updated:
        return NotificationMessageType.teamTop10Update;
      case NotificationConstants.notificationTypeRouteAssignmentUpdated:
        return NotificationMessageType.routeAssignmentUpdate;
      case NotificationConstants.notificationTypeAreaAssignmentUpdated:
        return NotificationMessageType.areaAssignmentUpdate;
      case NotificationConstants.notificationTypeChallengeMembershipTimeElapsed:
        return NotificationMessageType.challengeMembershipTimeElapsed;
      case NotificationConstants.notificationTypeChallengeMembershipTargetReached:
        return NotificationMessageType.challengeMembershipTargetReached;
    }
    logger.d('No push notification handler found for type `$type`');
    return null;
  }
}

extension RemoteMessageHandling on RemoteMessage {
  BaseNotificationHandler? getNotificationHandler() {
    final messageType = getMessageType();
    if (messageType == null) {
      return null;
    }
    return GetIt.I<BaseNotificationHandler>(instanceName: messageType.toString());
  }

  void processMessage(BuildContext? currentContext) {
    var handler = getNotificationHandler();
    handler?.processMessage(this, currentContext);
  }

  String? getPayload() {
    var handler = getNotificationHandler();
    return handler?.getPayload(this);
  }
}
