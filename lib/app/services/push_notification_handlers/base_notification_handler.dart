part of 'notification_handlers.dart';

abstract class BaseNotificationHandler {
  void processMessage(RemoteMessage message, BuildContext? context);
  String? getPayload(RemoteMessage message);
  void processPayload(NotificationResponse response, BuildContext? context);

  @protected
  void _navigateTo(BuildContext? context, String route) {
    if (context != null) {
      GoRouter.of(context).go(route);
    }
  }
}
