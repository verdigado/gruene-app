import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/widgets/event_detail.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as ({CalendarEvent event, DateTime recurrence})?;

    return Scaffold(
      appBar: MainAppBar(title: t.events.events),
      body: FutureLoadingScreen(
        load: extra == null
            ? () async {
                final event = await getEventById(eventId);
                return event != null ? (event: event, recurrence: event.start) : null;
              }
            : () async => extra,
        buildChild: (event, _) {
          if (event == null) {
            return ErrorScreen(errorMessage: t.events.eventNotFound, retry: () => getEventById(eventId));
          }

          final image = event.event.image;

          return ListView(
            children: [
              if (image != null) Image.network(image, width: double.infinity, fit: BoxFit.fitWidth),
              Padding(
                padding: const EdgeInsets.all(20),
                child: EventDetail(event: event.event, recurrence: event.recurrence),
              ),
            ],
          );
        },
      ),
    );
  }
}
