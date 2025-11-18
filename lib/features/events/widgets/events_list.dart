import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_card.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventsList extends StatelessWidget {
  final List<CalendarEvent> events;
  final List<Calendar> calendars;
  final DateTimeRange? dateRange;

  const EventsList({super.key, required this.events, required this.dateRange, required this.calendars});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEvents = events.groupEventsByMonth(dateRange);

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
                onTap: () => context.pushNested(
                  event.event.id,
                  extra: (event: event.event, recurrence: event.recurrence, calendar: event.event.calendar(calendars)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
