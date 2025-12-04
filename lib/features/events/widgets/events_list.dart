import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventsList extends StatelessWidget {
  final void Function() refresh;
  final List<Calendar> calendars;

  const EventsList({super.key, required this.calendars, required this.refresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final groupedEvents = state.events.groupEventsByMonth(state.dateRange);

        if (groupedEvents.isEmpty) {
          if (state.loading) {
            return Center(child: CircularProgressIndicator());
          }
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
                    onTap: () => context.pushNested(
                      event.event.id,
                      extra: (recurrence: event.recurrence, calendar: event.event.calendar(calendars)),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
