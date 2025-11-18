import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/widgets/event_detail.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as ({CalendarEvent event, DateTime recurrence, Calendar calendar})?;

    return Scaffold(
      appBar: MainAppBar(title: t.events.events),
      body: FutureLoadingScreen(
        load: extra == null
            ? () async {
                final data = await getEventById(eventId);
                return data != null ? (event: data.event, recurrence: data.event.start, calendar: data.calendar) : null;
              }
            : () async => extra,
        buildChild: (data, _) {
          if (data == null) {
            return ErrorScreen(errorMessage: t.events.eventNotFound, retry: () => getEventById(eventId));
          }

          final image = data.event.image;

          return ExpandingScrollView(
            children: [
              if (image != null) Image.network(image, width: double.infinity, fit: BoxFit.fitWidth),
              Padding(
                padding: const EdgeInsets.all(20),
                child: EventDetail(event: data.event, recurrence: data.recurrence, calendar: data.calendar),
              ),
            ],
          );
        },
      ),
    );
  }
}
