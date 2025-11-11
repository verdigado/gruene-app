import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/repository/events_repository.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
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
        load: () async => (await getEvents(), await readCalendarFilterKeys()),
        buildChild: (params, _) {
          final ((events, calendars), calendarFilterKeys) = params;
          final List<Calendar> initialCalendarFilters = calendarFilterKeys == null
              ? calendars
              : calendars.where((calendar) => calendarFilterKeys.contains(calendar.id)).nonNulls.toList();
          return EventsScreen(events: events, calendars: calendars, initialCalendarFilters: initialCalendarFilters);
        },
      ),
    );
  }
}

class EventsScreen extends StatefulWidget {
  final List<CalendarEvent> events;
  final List<Calendar> calendars;
  final List<Calendar> initialCalendarFilters;

  const EventsScreen({super.key, required this.initialCalendarFilters, required this.events, required this.calendars});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool isMapView = false;
  String _query = '';
  late List<Calendar> _selectedCalendars;
  DateTimeRange? _dateRange;
  final DateTimeRange defaultDateRange = DateTimeRange(start: startOfDay(), end: dateInfinity());

  @override
  void initState() {
    super.initState();
    _selectedCalendars = widget.initialCalendarFilters;
    _dateRange = defaultDateRange;
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events.filter(_selectedCalendars, _dateRange);

    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', selected: _query);
    final calendarFilter = FilterModel(
      update: (calendars) => setState(() => _selectedCalendars = calendars),
      initial: widget.calendars,
      selected: _selectedCalendars,
      values: widget.calendars,
    );
    final dateRangeFilter = FilterModel(
      update: (dateRange) => setState(() => _dateRange = dateRange),
      initial: defaultDateRange,
      selected: _dateRange,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: isMapView
              ? EventsMap(events: events)
              : Container(
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 64),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilterBar(
                        searchFilter: searchFilter,
                        modified: [calendarFilter, dateRangeFilter].modified(),
                        filterDialog: EventsFilterDialog(
                          calendarFilter: calendarFilter,
                          dateRangeFilter: dateRangeFilter,
                        ),
                      ),
                      Expanded(child: EventsList(events: events)),
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
              selected: {isMapView},
              onSelectionChanged: (newSelection) => setState(() => isMapView = newSelection.first),
              showSelectedIcon: false,
            ),
          ),
        ),
      ],
    );
  }
}
