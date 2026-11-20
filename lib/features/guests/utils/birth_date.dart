import 'package:gruene_app/app/utils/date.dart';
import 'package:intl/intl.dart';

final firstBirthDate = DateTime(1900);
final lastBirthDate = DateTime.now();

DateTime? parseBirthDate(String? value) {
  try {
    final date = DateFormat(dateFormat).parseStrict(value?.trim() ?? '');
    if (date.isBefore(firstBirthDate) || date.isAfter(lastBirthDate)) return null;
    return date;
  } on FormatException {
    return null;
  }
}
