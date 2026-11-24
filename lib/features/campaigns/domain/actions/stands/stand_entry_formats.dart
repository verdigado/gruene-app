import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';

/// How Termine are written in the stand detail and the Termin list, in local time.
class StandEntryFormats {
  static const _timeFormat = 'HH:mm';

  /// When a Termin takes place, e.g. "Mi. 04.11. · 19:57–21:57 Uhr", or with [withYear] "Mi. 04.11.2026 · …".
  static String when(StandEntryModel entry, {required bool withYear}) {
    final dateFormat = withYear ? t.campaigns.stand.entryDateLongFormat : t.campaigns.stand.entryDateShortFormat;
    final startAt = entry.startAt.toLocal();
    return t.campaigns.stand.entryWhen(
      date: DateFormat(dateFormat).format(startAt),
      from: DateFormat(_timeFormat).format(startAt),
      to: DateFormat(_timeFormat).format(entry.endAt.toLocal()),
    );
  }

  /// The dates of the earliest and the latest Termin, without times, e.g. "04.03.2026 – 04.11.2026".
  static String dateRange(List<StandEntryModel> entries) {
    final startDates = entries.map((e) => e.startAt.toLocal()).toList()..sort();
    final dateFormat = DateFormat(t.campaigns.stand.entryRangeDateFormat);
    return t.campaigns.stand.entryRange(
      from: dateFormat.format(startDates.first),
      to: dateFormat.format(startDates.last),
    );
  }

  static String flyerCount(StandEntryModel entry) => t.campaigns.stand.entryFlyerCount(count: entry.flyerCount);

  /// Newest first: latest date and start time at the top.
  static List<StandEntryModel> newestFirst(List<StandEntryModel> entries) =>
      [...entries]..sort((a, b) => b.startAt.compareTo(a.startAt));
}
