part of '../converters.dart';

extension NotificationResponseHandling on NotificationResponse {
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
