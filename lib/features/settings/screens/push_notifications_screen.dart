import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/widgets/toggle_list_item.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_bloc.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_event.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class PushNotificationsScreen extends StatelessWidget {
  const PushNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> localizedTitles = {
      SecureStorageKeys.pushNotificationsBV: t.settings.pushNotifications.pushNotificationsBV,
      SecureStorageKeys.pushNotificationsLV: t.settings.pushNotifications.pushNotificationsLV,
      SecureStorageKeys.pushNotificationsKV: t.settings.pushNotifications.pushNotificationsKV,
    };

    return BlocBuilder<PushNotificationSettingsBloc, PushNotificationSettingsState>(
      builder: (context, state) {
        final bloc = context.read<PushNotificationSettingsBloc>();

        final availableToggleEntries =
            state.toggles.entries.where((entry) => state.availableToggles.contains(entry.key)).toList();

        return ListView(
          children: [
            SizedBox(height: 36),
            ToggleListItem(
              title: t.settings.pushNotifications.disableAll,
              value: state.allDisabled,
              onChanged: (value) {
                if (value) {
                  bloc.add(DisableAllToggles());
                }
              },
            ),
            ...availableToggleEntries.map((entry) {
              return ToggleListItem(
                title: localizedTitles[entry.key]!,
                value: entry.value,
                onChanged: (bool newValue) {
                  bloc.add(TogglePushNotificationSetting(entry.key, newValue));
                },
              );
            }),
          ],
        );
      },
    );
  }
}
