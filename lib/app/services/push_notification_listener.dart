import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

class PushNotificationListener {
  final GlobalKey<NavigatorState> navigatorKey;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'default_channel',
    'Benachrichtigungen',
    description: 'Benachrichtigungen der Grünen App',
    importance: Importance.high,
  );

  String? _initialNewsId;
  String? get initialNewsId => _initialNewsId;

  PushNotificationListener(this.navigatorKey);

  Future<void> initialize() async {
    await _setupLocalNotifications();
    _registerForegroundMessageHandler();
    _registerNotificationTapHandler();
    _registerBackgroundHandler();
    _handleInitialMessage();
  }

  Future<void> _handleInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    _initialNewsId = message?.data['newsId']?.toString();
  }

  void _registerForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _registerNotificationTapHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final newsId = message.data['newsId'];
      if (newsId != null) {
        _navigateTo('/news/$newsId');
      }
    });

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: initializationSettingsDarwin,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('news.')) {
          final newsId = payload.replaceFirst('news.', '');
          _navigateTo('/news/$newsId');
        }
      },
    );
  }

  void _registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _setupLocalNotifications() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final newsId = message.data['newsId'];

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Benachrichtigung',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: newsId != null ? 'news.$newsId' : null,
      );
    }
  }

  void _navigateTo(String route) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(route);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
