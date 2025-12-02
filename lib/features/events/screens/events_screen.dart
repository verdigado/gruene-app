import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_edit_dialog.dart';
import 'package:gruene_app/features/events/widgets/events_filter_dialog.dart';
import 'package:gruene_app/features/events/widgets/events_list.dart';
import 'package:gruene_app/features/events/widgets/events_map.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventsScreenContainer extends StatelessWidget {
  const EventsScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.events.events),
      body: FutureLoadingScreen(
        load: getCalendars,
        buildChild: (calendars, _) => EventsScreen(calendars: calendars),
      ),
    );
  }
}

class EventsScreen extends StatelessWidget {
  final List<Calendar> calendars;

  const EventsScreen({super.key, required this.calendars});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 0), child: EventsFilterBar()),
        Expanded(child: EventsContent(calendars: calendars)),
      ],
    );
  }
}

class EventsContent extends StatefulWidget {
  final List<Calendar> calendars;

  const EventsContent({super.key, required this.calendars});

  @override
  State<EventsContent> createState() => _EventsContentState();
}

class _EventsContentState extends State<EventsContent> {
  bool showMap = false;

  @override
  Widget build(BuildContext context) {
    final writableCalendar = widget.calendars.firstWhereOrNull((calendar) => !calendar.readOnly);
    return Stack(
      children: [
        Offstage(
          offstage: !showMap,
          child: EventsMap(calendars: widget.calendars),
        ),
        Offstage(
          offstage: showMap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EventsList(
              calendars: widget.calendars,
              refresh: () => context.read<EventsBloc>().add(LoadEvents(force: true)),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Center(
            child: SegmentedButton(
              segments: [
                ButtonSegment(value: false, icon: const Icon(Icons.list), label: Text(t.events.list)),
                ButtonSegment(value: true, icon: const Icon(Icons.map), label: Text(t.events.map)),
              ],
              selected: {showMap},
              onSelectionChanged: (newSelection) => setState(() => showMap = newSelection.first),
              showSelectedIcon: false,
            ),
          ),
        ),
        if (writableCalendar != null)
          Positioned(
            bottom: 8,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () async {
                final event = await showFullScreenDialog<CalendarEvent?>(
                  context,
                  (_) => EventEditDialog(calendar: writableCalendar, event: null, context: context),
                );
                if (context.mounted && event != null) {
                  context.pushNested(
                    event.id,
                    extra: (recurrence: event.start, calendar: event.calendar(widget.calendars)),
                  );
                }
              },
              child: Icon(Icons.edit_calendar),
            ),
          ),
      ],
    );
  }
}
