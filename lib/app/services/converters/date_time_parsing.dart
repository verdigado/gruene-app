part of '../converters.dart';

extension DateTimeParsing on DateTime {
  String getAsLocalDateTimeString() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final dateString = DateFormat(t.campaigns.poster.date_format).format(localDateTime);
    final timeString = DateFormat(t.campaigns.poster.time_format).format(localDateTime);
    return t.campaigns.poster.datetime_display_template(date: dateString, time: timeString);
  }

  String getAsLocalDateString() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final dateString = DateFormat(t.campaigns.poster.date_format).format(localDateTime);
    return dateString;
  }

  String getAsLocalTimeString() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final timeString = DateFormat(t.campaigns.poster.time_format).format(localDateTime);
    return timeString;
  }

  String getAsTimeStamp() {
    DateTime utcDateTime = this;
    DateTime localDateTime = utcDateTime.toLocal();
    final timestampString = DateFormat(t.campaigns.poster.timestamp_format).format(localDateTime);
    return timestampString;
  }

  String getTimeRemaining() {
    DateTime endTime = this;
    DateTime currentTime = DateTime.now();
    Duration duration = endTime.difference(currentTime);
    if (duration.isNegative) {
      return t.campaigns.challenges.time_remaining.minutes(minutes: 0);
    }
    int days = duration.inDays;
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    if (days >= 14) {
      return t.campaigns.challenges.time_remaining.weeks(weeks: (days / 7).floor());
    } else if (days >= 3) {
      return t.campaigns.challenges.time_remaining.days(days: days);
    } else if (days >= 1) {
      return t.campaigns.challenges.time_remaining.hours(hours: hours);
    } else if (hours >= 4) {
      if (minutes % 60 >= 30) {
        return t.campaigns.challenges.time_remaining.halfhours(hours: hours);
      }
      return t.campaigns.challenges.time_remaining.hours(hours: hours);
    } else {
      return t.campaigns.challenges.time_remaining.minutes(minutes: minutes);
    }
  }
}
