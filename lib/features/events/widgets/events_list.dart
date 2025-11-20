import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventsList extends StatelessWidget {
  final void Function() refresh;
  final void Function(CalendarEvent event) update;
  final void Function(CalendarEvent event) delete;
  final List<CalendarEvent> events;
  final List<Calendar> calendars;
  final DateTimeRange? dateRange;

  const EventsList({
    super.key,
    required this.events,
    required this.dateRange,
    required this.calendars,
    required this.refresh,
    required this.update,
    required this.delete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEvents = events.groupEventsByMonth(dateRange);

    if (groupedEvents.isEmpty) {
      return ErrorScreen(errorMessage: t.events.noEvents, retry: refresh);
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 64),
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final group = groupedEvents[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(group.month.formattedMonth, style: theme.textTheme.titleMedium),
            ),
            ...group.events.map(
              (event) => EventCard(
                event: event.event,
                recurrence: event.recurrence,
                onTap: () async {
                  final updatedEvent = await context.pushNested(
                    event.event.id,
                    extra: (
                      event: event.event,
                      recurrence: event.recurrence,
                      calendar: event.event.calendar(calendars),
                    ),
                  );
                  if (updatedEvent != null) {
                    update(updatedEvent as CalendarEvent);
                  } else {
                    delete(event.event);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
