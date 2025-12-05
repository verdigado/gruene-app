import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
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

class EventsScreen extends StatefulWidget {
  final List<Calendar> calendars;

  const EventsScreen({super.key, required this.calendars});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool showMap = false;

  @override
  Widget build(BuildContext context) {
    final writableCalendars = widget.calendars.where((calendar) => !calendar.readOnly).toList();
    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) => showMap && state.events.isEmpty ? showSnackBar(context, t.events.noEvents) : null,
      child: Stack(
        children: [
          Offstage(
            offstage: !showMap,
            child: EventsMap(calendars: widget.calendars),
          ),
          Offstage(
            offstage: showMap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  EventsFilterBar(calendars: writableCalendars),
                  Expanded(
                    child: EventsList(
                      calendars: widget.calendars,
                      refresh: () => context.read<EventsBloc>().add(LoadEvents(force: true)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
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
          if (writableCalendars.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton.small(
                heroTag: 'create event',
                onPressed: () async {
                  final event = await showFullScreenDialog<CalendarEvent?>(
                    context,
                    (_) => EventEditDialog.create(calendars: writableCalendars),
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
      ),
    );
  }
}
