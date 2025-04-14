import 'package:gruene_app/app/enums/push_notification_topic_enum.dart';

class PushNotificationSettingsModel {
  /// Flag to toggle overall push notifications
  bool enabled;

  /// Map of topics and their enabled status
  Map<PushNotificationTopic, bool> topics;

  PushNotificationSettingsModel({
    required this.enabled,
    required this.topics,
  });
}
