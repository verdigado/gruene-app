part of 'notification_handlers.dart';

class ChallengeMembershipTargetReachedHandler extends BaseNotificationHandler {
  @override
  void processMessage(RemoteMessage message, BuildContext? context) {
    final challengeId = _getChallengeId(message);
    if (context == null || challengeId == null) return;
    ChallengeHelper.openChallenge(context, challengeId);
  }

  @override
  String? getPayload(RemoteMessage message) {
    final challengeId = _getChallengeId(message);
    return challengeId != null
        ? '${NotificationConstants.payloadCampaignsChallengeMembershipTargetReachedPrefix}$challengeId'
        : null;
  }

  @override
  void processPayload(NotificationResponse response, BuildContext? context) {
    final challengeId = response.payload?.replaceFirst(
      NotificationConstants.payloadCampaignsChallengeMembershipTargetReachedPrefix,
      '',
    );
    if (context == null || challengeId == null) return;
    ChallengeHelper.openChallenge(context, challengeId);
  }

  String? _getChallengeId(RemoteMessage message) {
    return message.data['challengeId']?.toString();
  }
}
