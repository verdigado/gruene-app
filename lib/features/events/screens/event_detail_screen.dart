import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/page_info.dart';
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

          final image = event.image;
          final description = event.description;
          final firstRecurrence = event.formattedFirstRecurrence();

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageInfo(icon: Icons.today, text: event.formattedDate),
                        if (firstRecurrence != null) Text(t.events.nextDate(date: firstRecurrence)),
                      ],
                    ),
                    EventLocation(event: event),
                    if (description != null) Text(description),
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

class EventLocation extends StatelessWidget {
  final CalendarEvent event;

  const EventLocation({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final locationAddress = event.locationAddress;
    final locationUrl = event.locationUrl;

    if (locationAddress == null && locationUrl == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (locationAddress != null) PageInfo(icon: Icons.location_on_outlined, text: locationAddress),
        if (locationUrl != null)
          PageInfo(icon: Icons.videocam_outlined, url: locationUrl),
      ],
    );
  }
}

