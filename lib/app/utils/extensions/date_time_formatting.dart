part of '../extensions.dart';

extension DateTimeFormatting on DateTime {
  String toLocalDateTimeString() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final dateString = DateFormat(t.common.dateTime.dateFormat).format(localDateTime);
    final timeString = DateFormat(t.common.dateTime.timeFormat).format(localDateTime);
    return t.common.dateTime.displayTemplate(date: dateString, time: timeString);
  }

  String toLocalDateString() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final dateString = DateFormat(t.common.dateTime.dateFormat).format(localDateTime);
    return dateString;
  }

  String toLocalTimeString() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final timeString = DateFormat(t.common.dateTime.timeFormat).format(localDateTime);
    return timeString;
  }

  String toTimeStamp() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final timestampString = DateFormat(t.common.dateTime.timestampFormat).format(localDateTime);
    return timestampString;
  }

  String getTimeRemaining() {
    DateTime endTime = this;
    DateTime currentTime = DateTime.now();
    Duration duration = endTime.difference(currentTime);
    if (duration.isNegative) {
      return t.common.dateTime.timeRemaining.minutes(minutes: 0);
    }
    int days = duration.inDays;
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    if (days >= 14) {
      return t.common.dateTime.timeRemaining.weeks(weeks: (days / 7).floor());
    } else if (days >= 3) {
      return t.common.dateTime.timeRemaining.days(days: days);
    } else if (days >= 1) {
      return t.common.dateTime.timeRemaining.hours(hours: hours);
    } else if (hours >= 4) {
      if (minutes % 60 >= 30) {
        return t.common.dateTime.timeRemaining.halfhours(hours: hours);
      }
      return t.common.dateTime.timeRemaining.hours(hours: hours);
    } else {
      return t.common.dateTime.timeRemaining.minutes(minutes: minutes);
    }
  }
}
