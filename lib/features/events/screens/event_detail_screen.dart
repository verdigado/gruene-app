import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
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
          return ListView(
            children: [
              if (event.image != null) ...[Image.network(event.image!, width: double.infinity, fit: BoxFit.fitWidth)],
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28),
                    Text(event.title, style: theme.textTheme.titleLarge),
                    SizedBox(height: 16),
                    Text(getEventLocationLabel(event), style: theme.textTheme.labelSmall),
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
