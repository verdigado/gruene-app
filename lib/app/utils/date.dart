import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const dateFormat = 'dd.MM.yyyy';
const timeFormat = 'HH:mm';
const dateTimeFormat = '$dateFormat, $timeFormat';

String timeSuffix() => Intl.getCurrentLocale().startsWith('de') ? ' Uhr' : '';

String formatDate(DateTime date) => DateFormat(dateFormat).format(date);

String formatTime(DateTime time) => '${DateFormat(timeFormat).format(time)}${timeSuffix()}';

String formatDateTime(DateTime dateTime) => '${DateFormat(dateTimeFormat).format(dateTime)}${timeSuffix()}';

String formatInterval(String start, String end) => '$start - $end';

String formatStartEnd(DateTime start, DateTime? end) {
  if (end == null || start == end) {
    return formatDateTime(start);
  } else if (DateUtils.isSameDay(start, end)) {
    return formatInterval(formatDateTime(start), formatTime(end));
  } else {
    return formatInterval(formatDateTime(start), formatDateTime(end));
  }
}

String formatMonth(DateTime month) => DateFormat.yMMMM().format(month);

DateTime dateInfinity() => DateTime(DateTime.now().year + 100);

DateTime startOfDay() => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

DateTimeRange todayOrFuture() => DateTimeRange(start: startOfDay(), end: dateInfinity());
