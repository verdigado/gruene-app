import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
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
        .map((recurrence) => recurrence.copyWith(isUtc: false));
  }

  bool inRange(DateTimeRange? dateRange) {
    if (dateRange == null) return true;

    if (rrule == null) {
      return !(start.isAfter(dateRange.end) || (end?.isBefore(dateRange.start) ?? true));
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
  List<CalendarEvent> filter(List<Calendar> calendars, List<String> categories, DateTimeRange? dateRange) {
    return where(
      (it) =>
          calendars.map((calendar) => calendar.id).contains(it.calendarId) &&
          (categories.isEmpty || it.categories.any((category) => categories.contains(category))) &&
          it.inRange(dateRange),
    ).toList();
  }

  List<MonthGroup> groupEventsByMonth(DateTimeRange? dateRange) {
    final Map<DateTime, List<({CalendarEvent event, DateTime recurrence})>> groupedMap = {};
    final now = DateTime.now();

    final eventsWithRecurrences = map(
      (event) =>
          event.recurrences(dateRange)?.map((recurrence) => (event, recurrence)).toList() ?? [(event, event.start)],
    ).expand((it) => it).toList();

    for (final (event, recurrence) in eventsWithRecurrences) {
      final startMonth = DateTime(recurrence.year, recurrence.month);
      final currentMonth = DateTime(now.year, now.month);
      final month = startMonth.isBefore(currentMonth) ? currentMonth : startMonth;
      groupedMap.putIfAbsent(month, () => []).add((event: event, recurrence: recurrence));
    }

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
