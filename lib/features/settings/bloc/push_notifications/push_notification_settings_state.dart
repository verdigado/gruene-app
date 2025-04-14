import 'package:gruene_app/app/enums/push_notification_topic_enum.dart';

class PushNotificationTopicGroup {
  final String name;
  final Map<PushNotificationTopic, bool> topics;

  const PushNotificationTopicGroup({
    required this.name,
    required this.topics,
  });
}

class PushNotificationSettingsState {
  // flag to toggle overall push notifications
  final bool enabled;
  final Map<PushNotificationTopic, bool> topics;

  const PushNotificationSettingsState({
    this.enabled = true,
    this.topics = const {},
  });

  PushNotificationSettingsState copyWith({
    bool? enabled,
    final Map<PushNotificationTopic, bool>? topics,
  }) {
    return PushNotificationSettingsState(
      enabled: enabled ?? this.enabled,
      topics: topics ?? this.topics,
    );
  }

  List<PushNotificationTopicGroup> getTopicGroups() {
    final List<PushNotificationTopicGroup> topicGroups = [];

    // add news group
    topicGroups.add(
      PushNotificationTopicGroup(
        name: 'News',
        topics: Map.fromEntries(
          topics.entries.where(
            (entry) => [
              PushNotificationTopic.newsBv,
              PushNotificationTopic.newsLv,
              PushNotificationTopic.newsKv,
            ].contains(entry.key),
          ),
        ),
      ),
    );

    return topicGroups;
  }
}
