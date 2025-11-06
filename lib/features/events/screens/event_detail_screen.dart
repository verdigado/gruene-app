import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/widgets/event_location.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = GoRouterState.of(context).extra as CalendarEvent?;
    return Scaffold(
      appBar: MainAppBar(title: t.events.events),
      body: FutureLoadingScreen(
        load: event == null ? () => getEventById(eventId) : () async => event,
        buildChild: (CalendarEvent? event, _) {
          if (event == null) {
            return ErrorScreen(errorMessage: t.events.eventNotFound, retry: () => getEventById(eventId));
          }
          final image = event.image;
          return ListView(
            children: [
              if (image != null) Image.network(image, width: double.infinity, fit: BoxFit.fitWidth),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text(event.title, style: theme.textTheme.titleLarge),
                    EventLocation(event: event),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
