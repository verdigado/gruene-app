import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/enums/push_notification_topic_enum.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/toggle_list_item.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_bloc.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_event.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class PushNotificationsScreen extends StatelessWidget {
  const PushNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<PushNotificationTopic, String> localizedTitles = {
      PushNotificationTopic.newsBv: t.settings.pushNotifications.pushNotificationsBV,
      PushNotificationTopic.newsLv: t.settings.pushNotifications.pushNotificationsLV,
      PushNotificationTopic.newsKv: t.settings.pushNotifications.pushNotificationsKV,
    };

    return BlocBuilder<PushNotificationSettingsBloc, PushNotificationSettingsState>(
      builder: (context, state) {
        final bloc = context.read<PushNotificationSettingsBloc>();

        return Scaffold(
          appBar: MainAppBar(title: t.settings.settings),
          body: ListView(
            children: [
              SizedBox(height: 36),
              ToggleListItem(
                title: t.settings.pushNotifications.disableAll,
                value: !state.enabled,
                onChanged: (value) {
                  bloc.add(ToggleEnabled());
                },
              ),
              ...state.getTopicGroups().expand((group) {
                return [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                    child: Text(group.name, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ...group.topics.entries.map((entry) {
                    return ToggleListItem(
                      title: localizedTitles[entry.key]!,
                      value: entry.value,
                      onChanged: state.enabled
                          ? (bool newValue) {
                              bloc.add(ToggleTopic(entry.key, newValue));
                            }
                          : null,
                    );
                  }),
                ];
              }),
            ],
          ),
        );
      },
    );
  }
}
