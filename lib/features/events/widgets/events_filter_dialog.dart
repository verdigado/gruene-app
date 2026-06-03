import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/date_range_filter.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/app/widgets/selection_view.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
import 'package:gruene_app/features/events/constants/index.dart';
import 'package:gruene_app/features/events/widgets/event_attendance_selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventsFilterDialog extends StatefulWidget {
  final FilterModel<Set<CalendarEventAttendanceStatus>> attendanceStatusFilter;
  final SelectionFilterModel<List<Calendar>, List<Calendar>> calendarFilter;
  final SelectionFilterModel<List<String>, List<String>> categoryFilter;
  final FilterModel<DateTimeRange> dateRangeFilter;

  const EventsFilterDialog({
    super.key,
    required this.attendanceStatusFilter,
    required this.calendarFilter,
    required this.categoryFilter,
    required this.dateRangeFilter,
  });

  @override
  State<EventsFilterDialog> createState() => _EventsFilterDialogState();
}

// showFullScreenDialog creates a new BuildContext, such that state updates in the parent do not update widgets in the dialog
// We therefore need a local copy to reflect the state changes here as well
class _EventsFilterDialogState extends State<EventsFilterDialog> {
  late Set<CalendarEventAttendanceStatus> _localSelectedAttendanceStatuses;
  late List<Calendar> _localSelectedCalendars;
  late List<String> _localSelectedCategories;
  late DateTimeRange? _localDateRange;

  @override
  void initState() {
    super.initState();
    _localSelectedAttendanceStatuses = widget.attendanceStatusFilter.current;
    _localSelectedCalendars = widget.calendarFilter.current;
    _localSelectedCategories = widget.categoryFilter.current;
    _localDateRange = widget.dateRangeFilter.current;
  }

  void resetFilters(BuildContext context) {
    setState(() => _localSelectedAttendanceStatuses = widget.attendanceStatusFilter.initial);
    setState(() => _localSelectedCategories = widget.categoryFilter.initial);
    setState(() => _localDateRange = widget.dateRangeFilter.initial);
    context.read<EventsBloc>().add(
      LoadEvents(
        query: defaultQuery,
        attendanceStatuses: defaultAttendanceStatuses,
        categories: defaultCategories,
        dateRange: defaultDateRange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtersModified =
        widget.attendanceStatusFilter.modified(_localSelectedAttendanceStatuses) ||
        widget.categoryFilter.modified(_localSelectedCategories) ||
        widget.dateRangeFilter.modified(_localDateRange);

    return FilterDialog(
      resetFilters: () => resetFilters(context),
      modified: filtersModified,
      children: [
        DateRangeFilter(
          title: t.events.dateRange,
          dateRange: _localDateRange,
          setDateRange: (dateRange) {
            setState(() => _localDateRange = dateRange ?? defaultDateRange);
            widget.dateRangeFilter.update(dateRange ?? defaultDateRange);
          },
        ),
        if (widget.calendarFilter.values.length > 1)
          SelectionView(
            setSelectedOptions: (calendars) {
              setState(() => _localSelectedCalendars = calendars);
              widget.calendarFilter.update(calendars);
            },
            title: t.events.calendars,
            options: widget.calendarFilter.values,
            selectedOptions: _localSelectedCalendars,
            getLabel: (calendar) => calendar.displayName,
          ),
        FilterSection(
          title: t.events.categories,
          child: MultiSelection(
            selected: _localSelectedCategories,
            setSelected: (categories) {
              setState(() => _localSelectedCategories = categories);
              widget.categoryFilter.update(categories);
            },
            items: eventCategories,
            compare: (category1, category2) => category1 == category2,
            filter: (category, query) => category.matches(query),
            itemAsString: (category) => category,
            hint: t.events.searchCategories,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(title: t.events.attendance),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EventAttendanceSelection(
                attendanceStatus: _localSelectedAttendanceStatuses,
                setAttendanceStatus: (attendanceStatuses) {
                  setState(() => _localSelectedAttendanceStatuses = attendanceStatuses);
                  widget.attendanceStatusFilter.update(attendanceStatuses);
                },
                multiSelect: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EventsFilterBar extends StatelessWidget {
  final List<Calendar> calendars;

  const EventsFilterBar({super.key, required this.calendars});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final searchFilter = FilterModel(
          update: (query) => context.read<EventsBloc>().add(LoadEvents(query: query)),
          initial: defaultQuery,
          current: state.query,
        );
        final calendarFilter = SelectionFilterModel(
          update: (calendars) => context.read<EventsBloc>().add(LoadEvents(calendars: calendars)),
          initial: calendars,
          current: state.calendars,
          values: calendars,
        );
        final dateRangeFilter = FilterModel(
          update: (dateRange) => context.read<EventsBloc>().add(LoadEvents(dateRange: dateRange)),
          initial: defaultDateRange,
          current: state.dateRange,
        );
        final categoryFilter = SelectionFilterModel(
          update: (categories) => context.read<EventsBloc>().add(LoadEvents(categories: categories)),
          initial: defaultCategories,
          current: state.categories,
          values: defaultCategories,
        );
        final attendanceStatusFilter = FilterModel(
          update: (attendanceStatuses) =>
              context.read<EventsBloc>().add(LoadEvents(attendanceStatuses: attendanceStatuses)),
          initial: defaultAttendanceStatuses,
          current: state.attendanceStatuses,
        );
        return FilterBar(
          searchFilter: searchFilter,
          modified: <FilterModel<dynamic>>[attendanceStatusFilter, categoryFilter, calendarFilter].modified(),
          loading: state.loading && state.events.isNotEmpty,
          filterDialog: EventsFilterDialog(
            attendanceStatusFilter: attendanceStatusFilter,
            calendarFilter: calendarFilter,
            categoryFilter: categoryFilter,
            dateRangeFilter: dateRangeFilter,
          ),
        );
      },
    );
  }
}
