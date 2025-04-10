abstract class PushNotificationSettingsEvent {}

class LoadPushNotificationSettings extends PushNotificationSettingsEvent {}

class TogglePushNotificationSetting extends PushNotificationSettingsEvent {
  final String key;
  final bool value;

  TogglePushNotificationSetting(this.key, this.value);
}

class DisableAllToggles extends PushNotificationSettingsEvent {}

class UpdateFirebaseSubscriptions extends PushNotificationSettingsEvent {}
