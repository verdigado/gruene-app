import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_entry_formats.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

StandEntryModel _entry(String id, DateTime startAt, {int flyerCount = 0}) =>
    StandEntryModel(id: id, startAt: startAt, endAt: startAt.add(const Duration(hours: 2)), flyerCount: flyerCount);

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'de_DE';
    await initializeDateFormatting('de_DE');
  });

  final wednesday = _entry('1', DateTime(2026, 11, 4, 19, 57));

  test('a Termin is written with weekday, date and times, without the year', () {
    expect(StandEntryFormats.when(wednesday, withYear: false), 'Mi. 04.11. · 19:57–21:57 Uhr');
  });

  test('a Termin in the full list is written with the year', () {
    expect(StandEntryFormats.when(wednesday, withYear: true), 'Mi. 04.11.2026 · 19:57–21:57 Uhr');
  });

  test('a Termin from the API (UTC) is written in local time', () {
    final utc = _entry('1', DateTime.utc(2026, 11, 4, 18, 57));
    final local = utc.startAt.toLocal();

    expect(StandEntryFormats.when(utc, withYear: false), contains(DateFormat('HH:mm').format(local)));
  });

  test('the date range runs from the earliest to the latest Termin, without times', () {
    final entries = [
      _entry('2', DateTime(2026, 11, 4, 10)),
      _entry('1', DateTime(2026, 3, 4, 10)),
      _entry('3', DateTime(2026, 6, 1, 10)),
    ];

    expect(StandEntryFormats.dateRange(entries), '04.03.2026 – 04.11.2026');
  });

  test('the flyer count of a Termin without flyers is 0', () {
    expect(StandEntryFormats.flyerCount(wednesday), '0 Flyer');
  });

  test('Termine are sorted newest first, by date and start time', () {
    final entries = [
      _entry('morning', DateTime(2026, 11, 4, 10)),
      _entry('older', DateTime(2026, 11, 3, 18)),
      _entry('evening', DateTime(2026, 11, 4, 18)),
    ];

    expect(StandEntryFormats.newestFirst(entries).map((e) => e.id), ['evening', 'morning', 'older']);
  });
}
