import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class FcmTopicService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = GetIt.instance<FlutterSecureStorage>();
  bool _initialized = false;

  static const String topicBV = SecureStorageKeys.pushNotificationsBV;
  static const String topicLV = SecureStorageKeys.pushNotificationsLV;
  static const String topicKV = SecureStorageKeys.pushNotificationsKV;

  FcmTopicService() {
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    if (_initialized) return;

    try {
      await _firebaseMessaging.requestPermission();
      _initialized = true;
    } catch (e) {
      logger.e('Failed to initialize Firebase Messaging: $e');
    }
  }

  Future<List<Map<String, String>>?> _generateTopicsForUser() async {
    String? accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
    if (accessToken == null) {
      return null;
    }

    List<Map<String, String>> topics = [];
    topics.add({'topic': topicBV, 'identifier': 'news.10000000'});

    List<String> memberships = (JwtDecoder.decode(accessToken)['groups'] as List?)
            ?.map((g) => g.toString())
            .where((group) => !group.contains('_'))
            .toList() ??
        [];

    for (String membership in memberships) {
      membership = membership.startsWith('2') ? '1${membership.substring(1)}' : membership;
      if (membership.length == 3) {
        topics.add({'topic': topicLV, 'identifier': 'news.$membership${'0' * 5}'});
      } else if (membership.length == 8) {
        topics.add({
          'topic': topicKV,
          'identifier': 'news.${membership.substring(0, membership.length - 2)}00',
        });
      }
    }

    return topics;
  }

  Future<Map<String, List<String>>> getAvailableTopics() async {
    final topics = await _generateTopicsForUser();
    final Map<String, List<String>> result = {
      'bundesverband': [],
      'landesverband': [],
      'kreisverband': [],
    };
    if (topics == null || topics.isEmpty) {
      return result;
    }

    for (final topic in topics) {
      final identifier = topic['identifier'];

      if (identifier != null) {
        switch (topic['topic']) {
          case topicBV:
            result['bundesverband']!.add(identifier);
            break;
          case topicLV:
            result['landesverband']!.add(identifier);
            break;
          case topicKV:
            result['kreisverband']!.add(identifier);
            break;
        }
      }
    }

    return result;
  }

  Future<List<String>> _getSubscribedTopics() async {
    final topicsString = await _secureStorage.read(key: SecureStorageKeys.subscribedTopics);
    if (topicsString == null || topicsString.isEmpty) {
      return [];
    }
    return topicsString.split(',');
  }

  Future<void> _saveSubscribedTopics(List<String> topics) async {
    if (topics.isEmpty) {
      await _secureStorage.delete(key: SecureStorageKeys.subscribedTopics);
    } else {
      await _secureStorage.write(key: SecureStorageKeys.subscribedTopics, value: topics.join(','));
    }
  }

  Future<void> unsubscribeFromAllTopics() async {
    try {
      final subscribedTopics = await _getSubscribedTopics();

      for (final topic in subscribedTopics) {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
        logger.d('Unsubscribed from topic: $topic');
      }

      await _saveSubscribedTopics([]);
    } catch (e) {
      logger.w('Error unsubscribing from topics: $e');
    }
  }

  Future<void> updateSubscriptions() async {
    final availableTopics = await getAvailableTopics();
    if (availableTopics.isEmpty ||
        (availableTopics['bundesverband']!.isEmpty &&
            availableTopics['landesverband']!.isEmpty &&
            availableTopics['kreisverband']!.isEmpty)) {
      logger.d('No topics available for subscription');
      return;
    }

    final subscriptionMap = {
      topicBV: availableTopics['bundesverband'] ?? [],
      topicLV: availableTopics['landesverband'] ?? [],
      topicKV: availableTopics['kreisverband'] ?? [],
    };

    final currentSubscriptions = await _getSubscribedTopics();
    final newSubscriptions = <String>[];
    final topicsToUnsubscribe = List.of(currentSubscriptions);

    for (final entry in subscriptionMap.entries) {
      final settingKey = entry.key;
      final topicValues = entry.value;

      if (topicValues.isEmpty) {
        continue;
      }

      final isEnabled = await _secureStorage.read(key: settingKey) == 'true';

      try {
        for (final topicValue in topicValues) {
          if (isEnabled) {
            if (!currentSubscriptions.contains(topicValue)) {
              await _firebaseMessaging.subscribeToTopic(topicValue);
              logger.d('Subscribed to topic: $topicValue');
            }
            newSubscriptions.add(topicValue);
            topicsToUnsubscribe.remove(topicValue);
          } else if (currentSubscriptions.contains(topicValue)) {
            topicsToUnsubscribe.remove(topicValue);
            await _firebaseMessaging.unsubscribeFromTopic(topicValue);
            logger.d('Unsubscribed from topic: $topicValue');
          }
        }
      } catch (e) {
        logger.w('Error managing subscriptions for ${entry.key}: $e');
      }
    }

    for (final topic in topicsToUnsubscribe) {
      try {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
        logger.d('Unsubscribed from outdated topic: $topic');
      } catch (e) {
        logger.w('Error unsubscribing from topic $topic: $e');
      }
    }

    await _saveSubscribedTopics(newSubscriptions);
  }
}
