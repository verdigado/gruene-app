import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_form_rules.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  group('defaultEntryTimes', () {
    ({TimeOfDay from, TimeOfDay to}) times(int hour, int minute) {
      final defaults = StandFormRules.defaultEntryTimes(DateTime(2026, 11, 4, hour, minute, 40));
      return (from: defaults.from, to: defaults.to);
    }

    test('ends at now rounded down to the nearest quarter hour and lasts two hours', () {
      expect(times(19, 52), (from: TimeOfDay(hour: 17, minute: 45), to: TimeOfDay(hour: 19, minute: 45)));
    });

    test('ends at now rounded up to the nearest quarter hour', () {
      expect(times(19, 53), (from: TimeOfDay(hour: 18, minute: 0), to: TimeOfDay(hour: 20, minute: 0)));
    });

    test('keeps a full quarter hour', () {
      expect(times(10, 30), (from: TimeOfDay(hour: 8, minute: 30), to: TimeOfDay(hour: 10, minute: 30)));
    });

    test('dates the Termin today', () {
      expect(StandFormRules.defaultEntryTimes(DateTime(2026, 11, 4, 19, 52)).date, DateTime(2026, 11, 4));
    });

    test('stays on the same day late in the evening', () {
      expect(times(23, 55), (from: TimeOfDay(hour: 21, minute: 45), to: TimeOfDay(hour: 23, minute: 45)));
    });

    test('starts at midnight at the earliest', () {
      expect(times(1, 0), (from: TimeOfDay(hour: 0, minute: 0), to: TimeOfDay(hour: 1, minute: 0)));
    });

    test('ends after it starts right after midnight', () {
      expect(times(0, 3), (from: TimeOfDay(hour: 0, minute: 0), to: TimeOfDay(hour: 0, minute: 15)));
    });
  });

  group('isAfterToday', () {
    final now = DateTime(2026, 11, 4, 19, 52);

    test('is false for today, also later today', () {
      expect(StandFormRules.isAfterToday(DateTime(2026, 11, 4, 23, 59), now), isFalse);
    });

    test('is false for a past date', () {
      expect(StandFormRules.isAfterToday(DateTime(2026, 11, 3), now), isFalse);
    });

    test('is true from tomorrow on', () {
      expect(StandFormRules.isAfterToday(DateTime(2026, 11, 5), now), isTrue);
    });
  });

  group('validateName', () {
    test('requires a name', () {
      expect(StandFormRules.validateName('   '), 'Bitte gib einen Namen ein.');
    });

    test('accepts 100 characters', () {
      expect(StandFormRules.validateName('a' * 100), isNull);
    });

    test('refuses more than 100 characters', () {
      expect(StandFormRules.validateName('a' * 101), 'Höchstens 100 Zeichen.');
    });
  });

  test('limits the description to 500 characters', () {
    expect(StandFormRules.validateDescription('a' * 500), isNull);
    expect(StandFormRules.validateDescription('a' * 501), 'Höchstens 500 Zeichen.');
  });

  test('limits the comment to 200 characters', () {
    expect(StandFormRules.validateComment('a' * 200), isNull);
    expect(StandFormRules.validateComment('a' * 201), 'Höchstens 200 Zeichen.');
  });

  group('validateTimes', () {
    test('accepts Bis after Von', () {
      expect(StandFormRules.validateTimes(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 10, minute: 1)), isNull);
    });

    test('refuses Bis equal to Von', () {
      expect(
        StandFormRules.validateTimes(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 10, minute: 0)),
        '"Bis" muss nach "Von" liegen.',
      );
    });

    test('refuses Bis before Von, as a Termin cannot cross midnight', () {
      expect(StandFormRules.validateTimes(TimeOfDay(hour: 22, minute: 0), TimeOfDay(hour: 1, minute: 0)), isNotNull);
    });
  });

  group('flyer count', () {
    test('accepts empty and whole numbers from 0', () {
      expect(StandFormRules.validateFlyerCount(''), isNull);
      expect(StandFormRules.validateFlyerCount('0'), isNull);
      expect(StandFormRules.validateFlyerCount('250'), isNull);
    });

    test('refuses negative and not whole numbers', () {
      expect(StandFormRules.validateFlyerCount('-1'), 'Bitte gib eine ganze Zahl ab 0 ein.');
      expect(StandFormRules.validateFlyerCount('1.5'), isNotNull);
    });

    test('saves an empty count as 0', () {
      expect(StandFormRules.flyerCountToSave('', isAfterToday: false), 0);
      expect(StandFormRules.flyerCountToSave('42', isAfterToday: false), 42);
    });

    test('saves no count for a Termin after today', () {
      expect(StandFormRules.flyerCountToSave('42', isAfterToday: true), isNull);
    });
  });

  group('overlap', () {
    setUpAll(() async {
      Intl.defaultLocale = 'de_DE';
      await initializeDateFormatting('de_DE');
    });

    final morning = StandEntryModel(
      id: 'morning',
      startAt: DateTime(2026, 11, 4, 10),
      endAt: DateTime(2026, 11, 4, 12),
      flyerCount: 0,
    );

    test('finds a Termin whose time overlaps', () {
      expect(StandFormRules.findOverlap(DateTime(2026, 11, 4, 11), DateTime(2026, 11, 4, 13), [morning]), morning);
      expect(StandFormRules.findOverlap(DateTime(2026, 11, 4, 9), DateTime(2026, 11, 4, 14), [morning]), morning);
    });

    test('a Termin starting when another ends does not overlap', () {
      expect(StandFormRules.findOverlap(DateTime(2026, 11, 4, 12), DateTime(2026, 11, 4, 14), [morning]), isNull);
      expect(StandFormRules.findOverlap(DateTime(2026, 11, 4, 8), DateTime(2026, 11, 4, 10), [morning]), isNull);
    });

    test('several Termine on the same day are allowed', () {
      expect(StandFormRules.findOverlap(DateTime(2026, 11, 4, 14), DateTime(2026, 11, 4, 16), [morning]), isNull);
    });

    test('compares the times of Termine from the API (UTC) with local times', () {
      final fromApi = StandEntryModel(
        id: 'api',
        startAt: DateTime(2026, 11, 4, 10).toUtc(),
        endAt: DateTime(2026, 11, 4, 12).toUtc(),
        flyerCount: 0,
      );
      expect(StandFormRules.findOverlap(DateTime(2026, 11, 4, 11), DateTime(2026, 11, 4, 13), [fromApi]), fromApi);
      expect(StandFormRules.findOverlap(DateTime(2026, 11, 4, 12), DateTime(2026, 11, 4, 13), [fromApi]), isNull);
    });

    test('the message names the overlapping Termin', () {
      expect(
        StandFormRules.overlapMessage(morning),
        'Dieser Termin überschneidet sich mit dem Termin am 04.11.2026 von 10:00 bis 12:00 Uhr.',
      );
    });
  });
}
