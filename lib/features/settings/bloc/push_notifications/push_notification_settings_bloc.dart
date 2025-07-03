import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/enums/push_notification_topic_enum.dart';
import 'package:gruene_app/app/models/push_notification_settings_model.dart';
import 'package:gruene_app/app/services/push_notification_service.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_event.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_state.dart';

class PushNotificationSettingsBloc extends Bloc<PushNotificationSettingsEvent, PushNotificationSettingsState> {
  final PushNotificationService _pushNotificationService = GetIt.instance<PushNotificationService>();

  PushNotificationSettingsBloc() : super(PushNotificationSettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTopic>(_onToggleTopic);
    on<ToggleEnabled>(_onToggleEnabled);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<PushNotificationSettingsState> emit) async {
    final settings = _pushNotificationService.getSettings();

    emit(state.copyWith(enabled: settings.enabled, topics: settings.topics));
  }

  Future<void> _onToggleTopic(ToggleTopic event, Emitter<PushNotificationSettingsState> emit) async {
    final updatedTopics = Map<PushNotificationTopic, bool>.from(state.topics);
    updatedTopics[event.topic] = event.value;

    _pushNotificationService.updateSettings(
      PushNotificationSettingsModel(enabled: state.enabled, topics: updatedTopics),
    );

    emit(state.copyWith(topics: updatedTopics));
  }

  Future<void> _onToggleEnabled(ToggleEnabled event, Emitter<PushNotificationSettingsState> emit) async {
    final updatedEnabled = !state.enabled;
    _pushNotificationService.updateSettings(
      PushNotificationSettingsModel(enabled: updatedEnabled, topics: state.topics),
    );

    emit(state.copyWith(enabled: updatedEnabled));
  }
}
