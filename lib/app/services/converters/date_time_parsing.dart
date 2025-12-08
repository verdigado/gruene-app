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
}
