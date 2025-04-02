class PushNotificationSettingsState {
  final Map<String, bool> toggles;
  final bool allDisabled;

  PushNotificationSettingsState(this.toggles, {bool? allDisabled})
      : allDisabled = allDisabled ?? toggles.values.every((v) => v == false);

  PushNotificationSettingsState copyWith({
    Map<String, bool>? toggles,
    bool? allDisabled,
  }) {
    return PushNotificationSettingsState(
      toggles ?? this.toggles,
      allDisabled: allDisabled ?? this.allDisabled,
    );
  }
}
