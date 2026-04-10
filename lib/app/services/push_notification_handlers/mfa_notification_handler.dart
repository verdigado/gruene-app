part of 'notification_handlers.dart';

class MfaNotificationHandler extends BaseNotificationHandler {
  @override
  void processMessage(RemoteMessage message, BuildContext? context) => _navigateToMfa(context);

  @override
  String? getPayload(RemoteMessage message) => NotificationConstants.payloadMfa;

  @override
  void processPayload(NotificationResponse response, BuildContext? context) => _navigateToMfa(context);

  void _navigateToMfa(BuildContext? context) {
    if (context == null) return;
    final authBloc = context.read<AuthBloc>();
    final isLoggedIn = authBloc.state is Authenticated;

    if (isLoggedIn) {
      GoRouter.of(context).go(RouteLocations.getRoute([RouteLocations.mfa]));
    } else {
      GoRouter.of(context).push(RouteLocations.getRoute([RouteLocations.mfaLogin]));
    }
  }
}
