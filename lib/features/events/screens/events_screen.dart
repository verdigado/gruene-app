import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/features/events/constants/index.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/repository/events_repository.dart';
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
        load: () async => (await getEvents(), await getCalendars(), await readCalendarFilterKeys()),
        buildChild: (data, extra) {
          final (events, calendars, calendarFilterKeys) = data;
          final List<Calendar> initialCalendarFilters = calendarFilterKeys == null
              ? calendars
              : calendars.where((calendar) => calendarFilterKeys.contains(calendar.id)).nonNulls.toList();
          return EventsScreen(
            events: events,
            calendars: calendars,
            initialCalendarFilters: initialCalendarFilters,
            updateEvents: (List<CalendarEvent> events) => extra.update((events, calendars, calendarFilterKeys)),
            refresh: extra.refresh,
          );
        },
      ),
    );
  }
}

class EventsScreen extends StatefulWidget {
  final void Function(List<CalendarEvent>) updateEvents;
  final void Function() refresh;
  final List<CalendarEvent> events;
  final List<Calendar> calendars;
  final List<Calendar> initialCalendarFilters;

  const EventsScreen({
    super.key,
    required this.initialCalendarFilters,
    required this.events,
    required this.calendars,
    required this.refresh,
    required this.updateEvents,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool isMapView = false;
  String _query = '';
  late List<Calendar> _selectedCalendars;
  List<String> _selectedCategories = [];
  DateTimeRange? _dateRange;

  void addOrUpdateEvent(CalendarEvent newEvent) async {
    final events = widget.events.where((event) => event.id != newEvent.id);
    final isNew = events.length == widget.events.length;
    widget.updateEvents([...events, newEvent].toList());
    if (isNew) {
      final updatedEvent = await context.pushNested(
        newEvent.id,
        extra: (event: newEvent, recurrence: newEvent.start, calendar: newEvent.calendar(widget.calendars)),
      );
      if (updatedEvent != null) {
        addOrUpdateEvent(updatedEvent as CalendarEvent);
      } else {
        deleteEvent(newEvent);
      }
    }
  }

  void deleteEvent(CalendarEvent deletedEvent) {
    final events = widget.events.where((event) => event.id != deletedEvent.id);
    widget.updateEvents(events.toList());
  }

  @override
  void initState() {
    super.initState();
    _selectedCalendars = widget.initialCalendarFilters;
    _dateRange = todayOrFuture();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events.filter(_selectedCalendars, _selectedCategories, _dateRange);
    final writableCalendar = widget.calendars.firstWhereOrNull((calendar) => !calendar.readOnly);

    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', selected: _query);
    final calendarFilter = FilterModel(
      update: (calendars) => setState(() => _selectedCalendars = calendars),
      initial: widget.calendars,
      selected: _selectedCalendars,
      values: widget.calendars,
    );
    final categoryFilter = FilterModel<List<String>>(
      update: (categories) => setState(() => _selectedCategories = categories),
      initial: [],
      selected: _selectedCategories,
      values: eventCategories,
    );
    final dateRangeFilter = FilterModel(
      update: (dateRange) => setState(() => _dateRange = dateRange),
      initial: todayOrFuture(),
      selected: _dateRange,
    );

    return Stack(
      children: [
        isMapView
            ? EventsMap(events: events, calendars: widget.calendars, update: addOrUpdateEvent)
            : Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    FilterBar(
                      searchFilter: searchFilter,
                      modified: [calendarFilter, categoryFilter, dateRangeFilter].modified(),
                      filterDialog: EventsFilterDialog(
                        calendarFilter: calendarFilter,
                        categoryFilter: categoryFilter,
                        dateRangeFilter: dateRangeFilter,
                      ),
                    ),
                    Expanded(
                      child: EventsList(
                        events: events,
                        calendars: widget.calendars,
                        dateRange: _dateRange,
                        refresh: widget.refresh,
                        update: addOrUpdateEvent,
                        delete: deleteEvent,
                      ),
                    ),
                  ],
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
              selected: {isMapView},
              onSelectionChanged: (newSelection) => setState(() => isMapView = newSelection.first),
              showSelectedIcon: false,
            ),
          ),
        ),
        if (writableCalendar != null)
          Positioned(
            bottom: 8,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () => showFullScreenDialog(
                context,
                (_) => EventEditDialog(
                  calendar: writableCalendar,
                  event: null,
                  context: context,
                  update: addOrUpdateEvent,
                ),
              ),
              child: Icon(Icons.edit_calendar),
            ),
          ),
      ],
    );
  }
}
