part of 'notification_handlers.dart';

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

  @override
  void processPayload(NotificationResponse response, BuildContext? context) {
    final newsId = response.payload?.replaceFirst('news.', '');
    _navigateTo(context, '${RouteLocations.getRoute([RouteLocations.news])}/$newsId');
  }

  String? _getNewsId(RemoteMessage message) {
    return message.data['newsId']?.toString();
  }
}
