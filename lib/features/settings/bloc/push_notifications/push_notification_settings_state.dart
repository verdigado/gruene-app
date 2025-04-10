class PushNotificationSettingsState {
  final Map<String, bool> toggles;
  final Set<String> availableToggles;
  final bool allDisabled;

  const PushNotificationSettingsState(
    this.toggles, {
    this.availableToggles = const {},
    this.allDisabled = false,
  });

  PushNotificationSettingsState copyWith({
    Map<String, bool>? toggles,
    Set<String>? availableToggles,
    bool? allDisabled,
  }) {
    return PushNotificationSettingsState(
      toggles ?? this.toggles,
      availableToggles: availableToggles ?? this.availableToggles,
      allDisabled: allDisabled ?? this.allDisabled,
    );
  }
}
