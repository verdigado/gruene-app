import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_card.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventsList extends StatelessWidget {
  final List<CalendarEvent> events;

  const EventsList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEvents = groupEventsByMonth(events);

    return ListView.builder(
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final group = groupedEvents[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(formatMonth(group.month), style: theme.textTheme.titleMedium),
            ),
            ...group.events.map(
              (event) => EventCard(
                event: event,
                onTap: () => context.pushNested(event.id, extra: event),
              ),
            ),
          ],
        );
      },
    );
  }
}
