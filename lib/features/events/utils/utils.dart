import 'package:gruene_app/features/events/models/month_group_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

List<MonthGroup> groupEventsByMonth(List<CalendarEvent> events) {
  final Map<DateTime, List<CalendarEvent>> groupedMap = {};

  for (var event in events) {
    final monthKey = DateTime(event.start.year, event.start.month);
    groupedMap.putIfAbsent(monthKey, () => []).add(event);
  }

  final List<MonthGroup> groupedList = groupedMap.entries.map((entry) {
    entry.value.sort((a, b) => a.start.compareTo(b.start));
    return MonthGroup(month: entry.key, events: entry.value);
  }).toList();

  groupedList.sort((a, b) => a.month.compareTo(b.month));

  return groupedList;
}

String formatEventDateRange(CalendarEvent event) {
  final start = event.start;
  final end = event.end;

  final dateFormat = DateFormat('dd.MM.yy, HH:mm', 'de_DE');
  final timeFormat = DateFormat('HH:mm', 'de_DE');

  if (end == null) {
    return '${dateFormat.format(start)} Uhr';
  } else if (start.year == end.year && start.month == end.month && start.day == end.day) {
    return '${dateFormat.format(start)} Uhr - ${timeFormat.format(end)} Uhr';
  } else {
    return '${dateFormat.format(start)} Uhr - ${dateFormat.format(end)} Uhr';
  }
}

String getEventLocationLabel(CalendarEvent event) {
  if (event.location != null && event.location!.trim().isNotEmpty) {
    return event.location!;
  } else if (event.locationType?.toLowerCase() == 'online') {
    return t.events.online;
  } else {
    return '';
  }
}
