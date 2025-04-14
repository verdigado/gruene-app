import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/enums/push_notification_topic_enum.dart';
import 'package:gruene_app/app/models/push_notification_settings_model.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PushNotificationService {
  late PushNotificationSettingsModel _settings;
  final FlutterSecureStorage _secureStorage = GetIt.instance<FlutterSecureStorage>();

  Future<void> initialize() async {
    await Firebase.initializeApp();

    final fb = FirebaseMessaging.instance;
    await fb.requestPermission();

    try {
      await fb.requestPermission();
    } catch (e) {
      logger.e('Failed to initialize Firebase Messaging: $e');
    }

    _settings = await _loadSettings();
  }

  /// Load Push Notification settings from secure storage
  PushNotificationSettingsModel getSettings() {
    return _settings;
  }

  /// Load Push Notification settings from secure storage
  Future<PushNotificationSettingsModel> _loadSettings() async {
    // load enabled flag from storage
    final enabledVal = await _secureStorage.read(key: SecureStorageKeys.pnEnabled);
    final enabled = enabledVal != null ? jsonDecode(enabledVal) as bool : true;

    // load topics from storage
    final topicsVal = await _secureStorage.read(key: SecureStorageKeys.pnTopicMap);

    final Map<String, dynamic> storedTopics =
        topicsVal != null ? (jsonDecode(topicsVal) as Map<String, dynamic>) : const {};

    // initialze all unset topics with true
    final Map<PushNotificationTopic, bool> topics = {};
    for (final topic in PushNotificationTopic.values) {
      topics[topic] = storedTopics[topic.name] as bool? ?? true;
    }

    return PushNotificationSettingsModel(
      enabled: enabled,
      topics: topics,
    );
  }

  /// Save Push Notification settings to secure storage
  Future<void> _saveSettings(PushNotificationSettingsModel model) async {
    await _secureStorage.write(key: SecureStorageKeys.pnEnabled, value: jsonEncode(model.enabled));
    // convert the topics map to a string map
    final Map<String, bool> topicMap = {};
    for (final entry in model.topics.entries) {
      topicMap[entry.key.name] = entry.value;
    }

    await _secureStorage.write(key: SecureStorageKeys.pnTopicMap, value: jsonEncode(topicMap));
  }

  // get fcm topic subscriptions stored in secure storage
  Future<List<String>> _loadSubscribedFcmTopics() async {
    final topicsVal = await _secureStorage.read(key: SecureStorageKeys.pnFcmTopics);
    if (topicsVal == null) {
      return const [];
    }
    try {
      final topics = jsonDecode(topicsVal) as List<dynamic>;
      return topics.map((e) => e.toString()).toList();
    } catch (e) {
      return const [];
    }
  }

  Future<void> updateSettings(PushNotificationSettingsModel settings) async {
    _settings = settings;
    _saveSettings(settings);
    await updateSubscriptions();
  }

  Future<void> updateSubscriptions() async {
    String? accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
    if (accessToken == null) {
      await _unsubscribeAll();
      return;
    }
    final token = JwtDecoder.decode(accessToken);

    List<String> groups = [];
    if (token['groups'] != null) {
      groups = token['groups'] as List<String>;
    }
    final newTopics = _getFcmTopics(groups);
    final currentTopics = (await _loadSubscribedFcmTopics()).toSet();

    final fb = FirebaseMessaging.instance;

    // Subscribe to new topics not currently subscribed
    final topicsToSubscribe = newTopics.difference(currentTopics);
    for (var topic in topicsToSubscribe) {
      try {
        await fb.subscribeToTopic(topic);
        logger.d('Subscribed to topic: $topic');
      } catch (e) {
        logger.w('Error subscribing to topic $topic: $e');
      }
    }

    // Unsubscribe from topics no longer needed
    final topicsToUnsubscribe = currentTopics.difference(newTopics);
    for (var topic in topicsToUnsubscribe) {
      try {
        await fb.unsubscribeFromTopic(topic);
        logger.d('Unsubscribed from topic: $topic');
      } catch (e) {
        logger.w('Error unsubscribing from topic $topic: $e');
      }
    }

    // Save the updated topics to secure storage
    await _secureStorage.write(key: SecureStorageKeys.pnFcmTopics, value: jsonEncode(newTopics.toList()));
  }

  /// Calculate the new list of all topics the user should be subscribed to
  /// based on the users oidc groups and user settings
  Set<String> _getFcmTopics(List<String> groups) {
    final Set<String> topics = {};

    if (!_settings.enabled) {
      return topics;
    }

    topicEnabled(PushNotificationTopic topic) => _settings.topics[topic] ?? true;

    if (topicEnabled(PushNotificationTopic.newsBv)) {
      topics.add('news.10000000');
    }

    for (final group in groups) {
      if (group.contains('_')) {
        continue;
      }

      if (group.length == 3 && topicEnabled(PushNotificationTopic.newsLv)) {
        final divisionKey = group.replaceFirst(RegExp(r'^2'), '1').padRight(8, '0');
        topics.add('news.$divisionKey');
      }

      if (group.length == 8 && topicEnabled(PushNotificationTopic.newsKv)) {
        final divisionKey = group.substring(0, 6).replaceFirst(RegExp(r'^2'), '1').padRight(8, '0');
        topics.add('news.$divisionKey');
      }
    }

    return topics;
  }

  // unsubscribe from all fcm topics, this does not clear the topic settings
  Future<void> _unsubscribeAll() async {
    final fb = FirebaseMessaging.instance;
    final topics = await _loadSubscribedFcmTopics();
    for (final topic in topics) {
      try {
        await fb.unsubscribeFromTopic(topic);
      } catch (e) {
        logger.w('Error unsubscribing from topic $topic: $e');
      }
    }

    await _secureStorage.write(key: SecureStorageKeys.pnFcmTopics, value: jsonEncode([]));
  }
}
