import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/features/events/models/month_group_model.dart';
import 'package:gruene_app/main.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart';

extension CalendarEventExtension on CalendarEvent {
  RecurrenceRule? get rrule => recurring != null ? RecurrenceRule.fromString(recurring!) : null;

  bool inRange(DateTimeRange? dateRange) {
    if (dateRange == null) return true;
    final rrule = this.rrule;

    if (rrule == null) {
      return !(start.isAfter(dateRange.end) || (end?.isBefore(dateRange.start) ?? true));
    }

    return formattedFirstRecurrence(dateRange) != null;
  }

  String? formattedFirstRecurrence([DateTimeRange? dateRange]) {
    final rrule = this.rrule;
    final end = this.end;

    if (rrule == null) return null;

    final between = dateRange ?? todayOrFuture();
    final recurrence = rrule
        .getInstances(start: between.start.copyWith(isUtc: true), before: between.end.copyWith(isUtc: true))
        .firstOrNull;

    if (recurrence == null) return null;

    final recurrenceStart = recurrence.copyWith(isUtc: false);
    final recurrenceEnd = end != null ? recurrenceStart.add(end.difference(start)) : null;

    return formatStartEnd(recurrenceStart, recurrenceEnd);
  }

  String get formattedDate {
    final rrule = this.rrule;

    if (rrule != null) {
      return rrule.toText(l10n: rruleL10n, untilDateFormat: DateFormat(dateFormat));
    }

    return formatStartEnd(start, end);
  }
}

extension CalendarEventListExtension on List<CalendarEvent> {
  List<CalendarEvent> filter(List<Calendar> calendars, DateTimeRange? dateRange) {
    return where(
      (it) => calendars.map((calendar) => calendar.id).contains(it.calendarId) && it.inRange(dateRange),
    ).toList();
  }
}

List<MonthGroup> groupEventsByMonth(List<CalendarEvent> events) {
  final Map<DateTime, List<CalendarEvent>> groupedMap = {};
  final now = DateTime.now();

  for (final event in events) {
    final startMonth = DateTime(event.start.year, event.start.month);
    final currentMonth = DateTime(now.year, now.month);
    final month = startMonth.isBefore(currentMonth) ? currentMonth : startMonth;
    groupedMap.putIfAbsent(month, () => []).add(event);
  }

  final groupedList = groupedMap.entries.map((entry) {
    entry.value.sort((a, b) => (a.start == b.start) ? a.title.compareTo(b.title) : a.start.compareTo(b.start));
    return MonthGroup(month: entry.key, events: entry.value);
  }).toList();

  groupedList.sort((a, b) => a.month.compareTo(b.month));

  return groupedList;
}
