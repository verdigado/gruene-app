part of '../converters.dart';

extension NullableRemoteMessageExtension on RemoteMessage? {
  NotificationMessageType? getMessageType() {
    if (this == null) return null;
    var type = this?.data['type'];

    switch (type) {
      case NotificationConstants.notificationTypeNews:
        return NotificationMessageType.news;
      case NotificationConstants.notificationTypeTeamMembershipUpdated:
        return NotificationMessageType.teamMembershipUpdate;
      case NotificationConstants.notificationTypeTeamTop10Updated:
        return NotificationMessageType.teamTop10Update;
      case NotificationConstants.notificationTypeRouteAssignmentUpdated:
        return NotificationMessageType.routeAssignmentUpdate;
      case NotificationConstants.notificationTypeAreaAssignmentUpdated:
        return NotificationMessageType.areaAssignmentUpdate;
    }
    return null;
  }
}

extension RemoteMessageExtension on RemoteMessage {
  BaseNotificationHandler getNotificationHandler() {
    final type = getMessageType();
    return GetIt.I<BaseNotificationHandler>(instanceName: type?.toString() ?? '');
  }

  void processMessage(BuildContext? currentContext) {
    var handler = getNotificationHandler();
    handler.processMessage(this, currentContext);
  }

  String? getPayload() {
    var handler = getNotificationHandler();
    return handler.getPayload(this);
  }
}

extension NotificationResponseExtension on NotificationResponse {
  BaseNotificationHandler? getNotificationHandler() {
    var localPayload = payload;
    NotificationMessageType? instanceIdentifier;
    if (localPayload == null) throw UnimplementedError();
    if (localPayload.startsWith(NotificationConstants.payloadNewsPrefix)) {
      instanceIdentifier = NotificationMessageType.news;
    } else if (localPayload == NotificationConstants.payloadTeam) {
      instanceIdentifier = NotificationMessageType.teamMembershipUpdate;
    } else if (localPayload == NotificationConstants.payloadTeamTop10) {
      instanceIdentifier = NotificationMessageType.teamTop10Update;
    } else {
      logger.e('Unknown notification payload: $localPayload');
      return null;
    }

    return GetIt.I<BaseNotificationHandler>(instanceName: instanceIdentifier.toString());
  }

  void processNotificationResponse(BuildContext? currentContext) {
    var handler = getNotificationHandler();
    handler?.processPayload(this, currentContext);
  }
}
