import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/format_date.dart';
import 'package:gruene_app/features/events/models/month_group_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

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

String formatEventDateRange(CalendarEvent event) {
  final start = event.start;
  final end = event.end;

  if (end == null || start == end) {
    return formatDateTime(start);
  } else if (DateUtils.isSameDay(start, end)) {
    return formatInterval(formatDateTime(start), formatTime(end));
  } else {
    return formatInterval(formatDateTime(start), formatDateTime(end));
  }
}
