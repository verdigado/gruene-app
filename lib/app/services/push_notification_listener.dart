import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gruene_app/app/services/converters.dart';

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

  RemoteMessage? _initialMessage;
  RemoteMessage? get initialMessage => _initialMessage;

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
    _initialMessage = message;
  }

  void _registerForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _registerNotificationTapHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      message.processMessage(navigatorKey.currentContext);
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
        response.processNotificationResponse(navigatorKey.currentContext);
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

    var handler = message.getNotificationHandler();

    String? payload = handler.getPayload(message);

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
        payload: payload,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
