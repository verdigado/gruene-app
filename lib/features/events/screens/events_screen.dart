import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/features/events/bloc/event_bloc.dart';
import 'package:gruene_app/features/events/constants/index.dart';
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
        buildChild: (calendars, _) => FutureLoadingScreen(
          load: () async {
            final events = await getEvents();
            if (context.mounted) {
              context.read<EventsBloc>().add(AddEvents(calendarEvents: events));
              return events;
            }
          },
          buildChild: (_, extra) => BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) =>
                EventsScreen(calendars: calendars, events: state.events, refresh: extra.refresh),
          ),
        ),
      ),
    );
  }
}

class EventsScreen extends StatefulWidget {
  final void Function() refresh;
  final List<Calendar> calendars;
  final List<CalendarEvent> events;

  const EventsScreen({super.key, required this.calendars, required this.events, required this.refresh});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _isMapView = false;
  String _query = '';
  List<String> _selectedCategories = [];
  Set<CalendarEventAttendanceStatus> _selectedAttendanceStatuses = {};
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = todayOrFuture();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events.filter(_selectedAttendanceStatuses, _selectedCategories, _dateRange);
    final writableCalendar = widget.calendars.firstWhereOrNull((calendar) => !calendar.readOnly);

    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', selected: _query);
    final attendanceStatusFilter = FilterModel<Set<CalendarEventAttendanceStatus>>(
      update: (attendanceStatuses) => setState(() => _selectedAttendanceStatuses = attendanceStatuses),
      initial: {},
      selected: _selectedAttendanceStatuses,
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
        Offstage(
          offstage: !_isMapView,
          child: EventsMap(events: events, calendars: widget.calendars),
        ),
        Offstage(
          offstage: _isMapView,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                FilterBar(
                  searchFilter: searchFilter,
                  modified: [attendanceStatusFilter, categoryFilter, dateRangeFilter].modified(),
                  filterDialog: EventsFilterDialog(
                    attendanceStatusFilter: attendanceStatusFilter,
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
                  ),
                ),
              ],
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
              selected: {_isMapView},
              onSelectionChanged: (newSelection) => setState(() => _isMapView = newSelection.first),
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
