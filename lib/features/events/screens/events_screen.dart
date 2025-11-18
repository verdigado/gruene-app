import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/features/events/constants/index.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/repository/events_repository.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_creation_dialog.dart';
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
  List<String> _selectedCategories = [];
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedCalendars = widget.initialCalendarFilters;
    _dateRange = todayOrFuture();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events.filter(_selectedCalendars, _selectedCategories, _dateRange);

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
            ? EventsMap(events: events)
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
                      child: EventsList(events: events, dateRange: _dateRange),
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
        // TODO only show button if write permissions for calendar
        Positioned(
          bottom: 8,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () => showFullScreenDialog(context, (_) => EventCreateDialog(calendar: widget.calendars.first)),
            child: Icon(Icons.edit_calendar),
          ),
        ),
      ],
    );
  }
}
