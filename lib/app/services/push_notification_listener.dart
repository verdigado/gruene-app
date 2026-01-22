import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
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
      var notificationHandler = message.getNotificationHandler();
      notificationHandler.processMessage(message, navigatorKey.currentContext);
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
        if (payload != null) {
          if (payload.startsWith('news.')) {
            final newsId = payload.replaceFirst('news.', '');
            _navigateTo('${RouteLocations.getRoute([RouteLocations.news])}/$newsId');
          } else if (payload == 'team') {
            _navigateTo(RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignTeamDetail]));
          }
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

class NewsNotificationHandler extends BaseNotificationHandler {
  @override
  void processMessage(RemoteMessage message, BuildContext? context) {
    var routerLocation = '${RouteLocations.getRoute([RouteLocations.news])}/${_getNewsId(message)}';
    _navigateTo(context, routerLocation);
  }

  @override
  String? getPayload(RemoteMessage message) {
    final newsId = _getNewsId(message);
    return newsId != null ? 'news.$newsId' : null;
  }

  String? _getNewsId(RemoteMessage message) {
    return message.data['newsId']?.toString();
  }
}

class TeamNotificationHandler extends BaseNotificationHandler {
  @override
  void processMessage(RemoteMessage message, BuildContext? context) {
    var routerLocation = RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignTeamDetail]);
    _navigateTo(context, routerLocation);
  }

  @override
  String? getPayload(RemoteMessage message) {
    return 'team';
  }
}

abstract class BaseNotificationHandler {
  void processMessage(RemoteMessage message, BuildContext? context);
  String? getPayload(RemoteMessage message);

  @protected
  void _navigateTo(BuildContext? context, String route) {
    if (context != null) {
      GoRouter.of(context).go(route);
    }
  }
}
