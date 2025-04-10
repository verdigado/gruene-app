import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/services/fcm_topic_service.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_event.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_state.dart';

class PushNotificationSettingsBloc extends Bloc<PushNotificationSettingsEvent, PushNotificationSettingsState> {
  final _secureStorage = GetIt.instance<FlutterSecureStorage>();
  final FcmTopicService _fcmTopicService = GetIt.instance<FcmTopicService>();

  final List<String> pushNotificationSettingKeys = [
    SecureStorageKeys.pushNotificationsBV,
    SecureStorageKeys.pushNotificationsLV,
    SecureStorageKeys.pushNotificationsKV,
  ];

  PushNotificationSettingsBloc() : super(PushNotificationSettingsState({})) {
    on<LoadPushNotificationSettings>(_onLoadPushNotificationSettings);
    on<TogglePushNotificationSetting>(_onTogglePushNotificationSetting);
    on<DisableAllToggles>(_onDisableAllToggles);
    on<UpdateFirebaseSubscriptions>(_onUpdateFirebaseSubscriptions);
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

    final availableTopics = await _fcmTopicService.getAvailableTopics();
    final availableToggles = <String>{
      if (availableTopics['bundesverband']!.isNotEmpty) SecureStorageKeys.pushNotificationsBV,
      if (availableTopics['landesverband']!.isNotEmpty) SecureStorageKeys.pushNotificationsLV,
      if (availableTopics['kreisverband']!.isNotEmpty) SecureStorageKeys.pushNotificationsKV,
    };

    bool allTogglesOff = true;
    for (final key in pushNotificationSettingKeys) {
      if (newValues[key] == true) {
        allTogglesOff = false;
        break;
      }
    }

    emit(
      state.copyWith(
        toggles: newValues,
        availableToggles: availableToggles,
        allDisabled: allTogglesOff,
      ),
    );

    add(UpdateFirebaseSubscriptions());
  }

  Future<void> _onTogglePushNotificationSetting(
    TogglePushNotificationSetting event,
    Emitter<PushNotificationSettingsState> emit,
  ) async {
    await _secureStorage.write(key: event.key, value: event.value.toString());

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

    add(UpdateFirebaseSubscriptions());
  }

  Future<void> _onDisableAllToggles(
    DisableAllToggles event,
    Emitter<PushNotificationSettingsState> emit,
  ) async {
    final updated = <String, bool>{};
    for (final key in pushNotificationSettingKeys) {
      await _secureStorage.write(key: key, value: 'false');
      updated[key] = false;
    }

    emit(state.copyWith(toggles: updated, allDisabled: true));

    add(UpdateFirebaseSubscriptions());
  }

  Future<void> _onUpdateFirebaseSubscriptions(
    UpdateFirebaseSubscriptions event,
    Emitter<PushNotificationSettingsState> emit,
  ) async {
    await _fcmTopicService.updateSubscriptions();
  }
}
