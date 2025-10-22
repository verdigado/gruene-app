import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

class EventsListView extends StatelessWidget {
  final List<CalendarEvent> events;

  const EventsListView({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEvents = groupEventsByMonth(events);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final group = groupedEvents[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(DateFormat.yMMMM('de_DE').format(group.month), style: theme.textTheme.titleMedium),
            ),
            ...group.events.map((event) => _EventCard(event: event)),
          ],
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = event.image != null && event.image!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 1), blurRadius: 12)],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.pushNested(event.id, extra: event),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    color: Colors.grey[200],
                    image: hasImage ? DecorationImage(image: NetworkImage(event.image!), fit: BoxFit.cover) : null,
                  ),
                  child: !hasImage
                      ? const Center(child: Icon(Icons.calendar_today, size: 52, color: Colors.white))
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatEventDateRange(event), style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(event.title, style: theme.textTheme.titleSmall?.copyWith(height: 1.375)),
                        const SizedBox(height: 12),
                        Text(getEventLocationLabel(event), style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
