import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_event.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_state.dart';

class PushNotificationSettingsBloc extends Bloc<PushNotificationSettingsEvent, PushNotificationSettingsState> {
  final _secureStorage = GetIt.instance<FlutterSecureStorage>();

  final List<String> pushNotificationSettingKeys = [
    SecureStorageKeys.pushNotificationsBV,
    SecureStorageKeys.pushNotificationsLV,
    SecureStorageKeys.pushNotificationsKV,
  ];

  PushNotificationSettingsBloc() : super(PushNotificationSettingsState({})) {
    on<LoadPushNotificationSettings>(_onLoadPushNotificationSettings);
    on<TogglePushNotificationSetting>(_onTogglePushNotificationSetting);
    on<DisableAllToggles>(_onDisableAllToggles);
  }

  Future<void> _onLoadPushNotificationSettings(
    LoadPushNotificationSettings event,
    Emitter<PushNotificationSettingsState> emit,
  ) async {
    final newValues = <String, bool>{};
    for (final key in pushNotificationSettingKeys) {
      final value = await _secureStorage.read(key: key);
      newValues[key] = value == 'true';
    }

    emit(PushNotificationSettingsState(newValues));
  }

  Future<void> _onTogglePushNotificationSetting(
    TogglePushNotificationSetting event,
    Emitter<PushNotificationSettingsState> emit,
  ) async {
    await _secureStorage.write(key: event.key, value: event.value.toString());

    // TODO: add firebase logic to subscribe or unsubscribe to/from topic

    final updated = Map<String, bool>.from(state.toggles);
    updated[event.key] = event.value;

    bool allTogglesOff = true;
    for (final key in pushNotificationSettingKeys) {
      if (updated[key] == true) {
        allTogglesOff = false;
        break;
      }
    }

    emit(state.copyWith(toggles: updated, allDisabled: allTogglesOff));
  }

  Future<void> _onDisableAllToggles(DisableAllToggles event, Emitter<PushNotificationSettingsState> emit) async {
    final updated = <String, bool>{};
    for (final key in pushNotificationSettingKeys) {
      await _secureStorage.write(key: key, value: 'false');
      updated[key] = false;

      // TODO: add firebase logic to unsubscribe from topic
    }
    emit(PushNotificationSettingsState(updated, allDisabled: true));
  }
}
