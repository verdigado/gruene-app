part of '../converters.dart';

extension NullableRemoteMessageExtension on RemoteMessage? {
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

extension RemoteMessageExtension on RemoteMessage {
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

extension NotificationResponseExtension on NotificationResponse {
  BaseNotificationHandler? getNotificationHandler() {
    var localPayload = payload;
    NotificationMessageType? instanceIdentifier;
    if (localPayload == null || localPayload.trim().isEmpty) throw UnimplementedError();
    if (localPayload.startsWith(NotificationConstants.payloadNewsPrefix)) {
      instanceIdentifier = NotificationMessageType.news;
    } else if (localPayload.startsWith(NotificationConstants.payloadMfa)) {
      instanceIdentifier = NotificationMessageType.mfa;
    } else if (localPayload.startsWith(NotificationConstants.payloadCampaignsChallengeMembershipTimeElapsedPrefix)) {
      instanceIdentifier = NotificationMessageType.challengeMembershipTimeElapsed;
    } else if (localPayload.startsWith(NotificationConstants.payloadCampaignsChallengeMembershipTargetReachedPrefix)) {
      instanceIdentifier = NotificationMessageType.challengeMembershipTargetReached;
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
