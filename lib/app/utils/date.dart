import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const dateFormat = 'dd.MM.yyyy';
const timeFormat = 'HH:mm';
const dateTimeFormat = '$dateFormat, $timeFormat';

extension DateTimeExtension on DateTime {
  String get formattedDate => DateFormat(dateFormat).format(toLocal());

  String get formattedTime => DateFormat(timeFormat).format(toLocal());

  String get formattedDateTime => DateFormat(dateTimeFormat).format(toLocal());

  String get formattedMonth => DateFormat.yMMMM().format(toLocal());

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get startOfHour => DateTime(year, month, day, hour);
}

DateTime dateInfinity() => DateTime(2100);

String formatInterval(String start, String end) => '$start - $end';

String formatStartEnd(DateTime start, DateTime? end) {
  if (end == null || start == end) {
    return start.formattedDateTime;
  } else if (DateUtils.isSameDay(start, end)) {
    return formatInterval(start.formattedDateTime, end.formattedTime);
  } else {
    return formatInterval(start.formattedDateTime, end.formattedDateTime);
  }
}

DateTimeRange todayOrFuture() => DateTimeRange(start: DateTime.now().startOfDay, end: dateInfinity());
