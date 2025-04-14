import 'package:gruene_app/app/enums/push_notification_topic_enum.dart';

abstract class PushNotificationSettingsEvent {}

class LoadSettings extends PushNotificationSettingsEvent {}

class ToggleTopic extends PushNotificationSettingsEvent {
  final PushNotificationTopic topic;
  final bool value;

  ToggleTopic(this.topic, this.value);
}

class ToggleEnabled extends PushNotificationSettingsEvent {}
