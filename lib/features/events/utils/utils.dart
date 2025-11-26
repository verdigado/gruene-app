import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/events/models/month_group_model.dart';
import 'package:gruene_app/main.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart';

const maxRecurrences = 30;

enum RecurrenceEndType { until, count }

extension CalendarEventExtension on CalendarEvent {
  RecurrenceRule? get rrule => recurring != null ? RecurrenceRule.fromString(recurring!) : null;

  String? get formattedRrule => rrule?.toText(l10n: rruleL10n, untilDateFormat: DateFormat(dateFormat));

  Iterable<DateTime>? recurrences([DateTimeRange? dateRange]) {
    final rrule = this.rrule;

    if (rrule == null) return null;

    final between = dateRange ?? todayOrFuture();
    return rrule
        .getInstances(start: between.start.copyWith(isUtc: true), before: between.end.copyWith(isUtc: true))
        .take(maxRecurrences)
        .map(
          (recurrence) => recurrence.copyWith(isUtc: false, hour: start.toLocal().hour, minute: start.toLocal().minute),
        );
  }

  bool inRange(DateTimeRange? dateRange) {
    if (dateRange == null) return true;

    if (rrule == null) {
      return !(start.isAfter(dateRange.end) || (end?.isBefore(dateRange.start) ?? false));
    }

    return recurrences(dateRange)?.firstOrNull != null;
  }

  DateTime nextDate(DateTime? recurrence) => recurrence ?? recurrences()?.firstOrNull ?? start;

  String formattedDate(DateTime? recurrence) {
    final start = nextDate(recurrence);
    final end = this.end != null ? start.add(this.end!.difference(this.start)) : null;
    return formatStartEnd(start, end);
  }

  Calendar calendar(List<Calendar> calendars) => calendars.firstWhere((calendar) => calendar.id == calendarId);
}

extension CalendarEventListExtension on List<CalendarEvent> {
  List<CalendarEvent> filter(
    List<Calendar> calendars,
    Set<CalendarEventAttendanceStatus> attendanceStatuses,
    List<String> categories,
    DateTimeRange? dateRange,
  ) {
    return where(
      (it) =>
          calendars.map((calendar) => calendar.id).contains(it.calendarId) &&
          (attendanceStatuses.isEmpty || attendanceStatuses.contains(it.attendanceStatus)) &&
          (categories.isEmpty || it.categories.any((category) => categories.contains(category))) &&
          it.inRange(dateRange),
    ).toList();
  }

  List<MonthGroup> groupEventsByMonth(DateTimeRange? dateRange) {
    final now = DateTime.now();
    final eventsWithRecurrences = map(
      (event) =>
          event.recurrences(dateRange)?.map((recurrence) => (event: event, recurrence: recurrence)).toList() ??
          [(event: event, recurrence: event.start)],
    ).expand((it) => it).toList();

    final groupedMap = eventsWithRecurrences.groupBy((event) {
      final startMonth = DateTime(event.recurrence.year, event.recurrence.month);
      final currentMonth = DateTime(now.year, now.month);
      return startMonth.isBefore(currentMonth) ? currentMonth : startMonth;
    });

    final groupedList = groupedMap.entries.map((entry) {
      entry.value.sort(
        ((a, b) => (a.recurrence == b.recurrence)
            ? a.event.title.compareTo(b.event.title)
            : a.recurrence.compareTo(b.recurrence)),
      );
      return MonthGroup(month: entry.key, events: entry.value);
    }).toList();

    groupedList.sort((a, b) => a.month.compareTo(b.month));

    return groupedList;
  }
}

extension RruleExtension on RecurrenceRule? {
  RecurrenceEndType? get recurrenceEndType {
    if (this?.until != null) return RecurrenceEndType.until;
    if (this?.count != null) return RecurrenceEndType.count;
    return null;
  }
}

extension CalendarEventAttendanceStatusExtension on CalendarEventAttendanceStatus? {
  Widget? icon(BuildContext context, [double? size]) {
    final theme = Theme.of(context);
    switch (this) {
      case CalendarEventAttendanceStatus.accepted:
        return Icon(Icons.check, color: theme.colorScheme.primary, size: size);
      case CalendarEventAttendanceStatus.tentative:
        return Icon(Icons.question_mark, color: ThemeColors.warning, size: size);
      case CalendarEventAttendanceStatus.declined:
        return Icon(Icons.close, color: theme.colorScheme.error, size: size);
      default:
        return null;
    }
  }
}
