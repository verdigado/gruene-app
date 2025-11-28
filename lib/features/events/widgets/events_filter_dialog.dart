import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/widgets/date_range_filter.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection_view.dart';
import 'package:gruene_app/features/events/constants/index.dart';
import 'package:gruene_app/features/events/widgets/event_attendance_selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventsFilterDialog extends StatefulWidget {
  final FilterModel<Set<CalendarEventAttendanceStatus>> attendanceStatusFilter;
  final FilterModel<List<String>> categoryFilter;
  final FilterModel<DateTimeRange?> dateRangeFilter;

  const EventsFilterDialog({
    super.key,
    required this.attendanceStatusFilter,
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
  late List<String> _localSelectedCategories;
  late DateTimeRange? _localDateRange;

  @override
  void initState() {
    super.initState();
    _localSelectedAttendanceStatuses = widget.attendanceStatusFilter.selected;
    _localSelectedCategories = widget.categoryFilter.selected;
    _localDateRange = widget.dateRangeFilter.selected;
  }

  void resetFilters() {
    setState(() => _localSelectedAttendanceStatuses = widget.attendanceStatusFilter.initial);
    widget.categoryFilter.reset();
    setState(() => _localSelectedCategories = widget.categoryFilter.initial);
    widget.dateRangeFilter.reset();
    setState(() => _localDateRange = widget.dateRangeFilter.initial);
  }

  @override
  Widget build(BuildContext context) {
    final filtersModified =
        widget.attendanceStatusFilter.modified(_localSelectedAttendanceStatuses) ||
        widget.categoryFilter.modified(_localSelectedCategories) ||
        widget.dateRangeFilter.modified(_localDateRange);

    return FilterDialog(
      resetFilters: resetFilters,
      modified: filtersModified,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(title: t.events.attendance),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
        SelectionView(
          setSelectedOptions: (categories) {
            setState(() => _localSelectedCategories = categories);
            widget.categoryFilter.update(categories);
          },
          title: t.events.categories,
          options: prominentEventCategories,
          moreOptionsTitle: t.events.moreCategories,
          moreOptions: moreEventCategories,
          selectedOptions: _localSelectedCategories,
          getLabel: (category) => category,
        ),
        DateRangeFilter(
          title: t.events.dateRange,
          dateRange: _localDateRange,
          setDateRange: (dateRange) {
            setState(() => _localDateRange = dateRange);
            widget.dateRangeFilter.update(dateRange);
          },
        ),
      ],
    );
  }
}
