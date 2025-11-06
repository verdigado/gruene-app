import 'package:intl/intl.dart';

const dateFormat = 'dd.MM.yyyy';
const timeFormat = 'HH:mm';
const dateTimeFormat = '$dateFormat, $timeFormat';

String timeSuffix() => Intl.getCurrentLocale().startsWith('de') ? ' Uhr' : '';

String formatDate(DateTime date) => DateFormat(dateFormat).format(date);

String formatTime(DateTime time) => '${DateFormat(timeFormat).format(time)}${timeSuffix()}';

String formatDateTime(DateTime dateTime) => '${DateFormat(dateTimeFormat).format(dateTime)}${timeSuffix()}';

String formatInterval(String start, String end) => '$start - $end';

String formatMonth(DateTime month) => DateFormat.yMMMM().format(month);
