import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_entry_edit.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const _flyerCount = 'Verteilte Flyer (optional)';
const _futureHint = 'Verteilte Flyer kannst du eintragen, sobald der Termin stattgefunden hat.';
const _lastEntryHint =
    'Der einzige Termin eines Stands kann nicht gelöscht werden. '
    'Wenn der Stand weg soll, lösche ihn unter „Wahlkampfstand bearbeiten“.';

/// Wednesday, 4 November 2026, 19:52.
DateTime _now() => DateTime(2026, 11, 4, 19, 52);

StandEntryModel _entry(String id, DateTime startAt, {int flyerCount = 0}) =>
    StandEntryModel(id: id, startAt: startAt, endAt: startAt.add(const Duration(hours: 2)), flyerCount: flyerCount);

Finder get _flyerCountInput => find.descendant(
  of: find.byWidgetPredicate((w) => w is TextInputField && w.labelText == _flyerCount),
  matching: find.byType(TextField),
);

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'de_DE';
    await initializeDateFormatting('de_DE');
  });

  late List<StandEntryUpdateModel> saved;
  late List<String> deleted;

  /// If set, saving waits for it, like the queue writing to its database.
  Completer<void>? saveGate;

  /// Opens the Termin like the stand edit view does ([MapConsumer.showModalEditForm]).
  Future<void> openEntry(
    WidgetTester tester,
    StandEntryModel entry, {
    List<StandEntryModel> otherEntries = const [],
    bool canDelete = true,
    double textScale = 1,
  }) async {
    saved = [];
    deleted = [];
    saveGate = null;
    tester.view.physicalSize = const Size(411, 900) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => MapConsumer.showModalEditForm(
                context,
                () => StandEntryEdit(
                  entry: entry,
                  otherEntries: otherEntries,
                  standName: 'Infostand am S-Bahnhof',
                  onSave: (update) async {
                    saved.add(update);
                    await saveGate?.future;
                  },
                  onDelete: canDelete ? (id) async => deleted.add(id) : null,
                  now: _now,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  bool isOpen() => find.text('Termin bearbeiten').evaluate().isNotEmpty;

  final pastEntry = _entry('7', DateTime(2026, 11, 2, 10), flyerCount: 80);

  testWidgets('shows the Termin with its date, times and flyers', (tester) async {
    await openEntry(tester, pastEntry);

    expect(find.text('Termin bearbeiten'), findsOneWidget);
    expect(find.text('Infostand am S-Bahnhof'), findsOneWidget);
    expect(find.text('Montag, 2. November 2026'), findsOneWidget);
    expect(find.text('10:00 AM'), findsOneWidget);
    expect(find.text('12:00 PM'), findsOneWidget);
    expect(tester.widget<TextField>(_flyerCountInput).controller!.text, '80');
  });

  testWidgets('saves the changed flyer count with the same times and closes', (tester) async {
    await openEntry(tester, pastEntry);

    await tester.enterText(_flyerCountInput, '95');
    await tapVisible(tester, find.text('Speichern'));

    final update = saved.single;
    expect(update.entryId, '7');
    expect(update.startAt, DateTime(2026, 11, 2, 10));
    expect(update.endAt, DateTime(2026, 11, 2, 12));
    expect(update.flyerCount, 95);
    expect(isOpen(), isFalse);
  });

  testWidgets('a second tap on Speichern while saving does not save the Termin twice', (tester) async {
    await openEntry(tester, pastEntry);
    saveGate = Completer<void>();

    await tester.ensureVisible(find.text('Speichern'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    saveGate!.complete();
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    expect(isOpen(), isFalse);
  });

  testWidgets('a failed save says so and stays open', (tester) async {
    await openEntry(tester, pastEntry);
    // ignore() keeps the error from counting as unhandled before the save waits for it
    saveGate = Completer<void>()
      ..future.ignore()
      ..completeError(Exception('database not available'));

    await tapVisible(tester, find.text('Speichern'));

    expect(find.text('Die Änderung konnte nicht gespeichert werden. Bitte versuche es noch einmal.'), findsOneWidget);
    expect(isOpen(), isTrue);
  });

  testWidgets('an emptied flyer count is saved as 0', (tester) async {
    await openEntry(tester, pastEntry);

    await tester.enterText(_flyerCountInput, '');
    await tapVisible(tester, find.text('Speichern'));

    expect(saved.single.flyerCount, 0);
  });

  testWidgets('a Termin after today has no flyer count and says why', (tester) async {
    await openEntry(tester, _entry('8', DateTime(2026, 11, 20, 10)));

    expect(tester.widget<TextField>(_flyerCountInput).enabled, isFalse);
    expect(tester.widget<TextField>(_flyerCountInput).controller!.text, isEmpty);
    expect(find.text(_futureHint), findsOneWidget);

    await tapVisible(tester, find.text('Speichern'));
    expect(saved.single.flyerCount, isNull);
  });

  testWidgets('moving a Termin with flyers after today clears the flyers after asking', (tester) async {
    await openEntry(tester, pastEntry);

    await tapVisible(tester, find.text('Montag, 2. November 2026'));
    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Für einen Termin in der Zukunft'), findsOneWidget);
    await tester.tap(find.text('Datum übernehmen'));
    await tester.pumpAndSettle();

    expect(find.text('Freitag, 20. November 2026'), findsOneWidget);
    expect(tester.widget<TextField>(_flyerCountInput).controller!.text, isEmpty);
    await tapVisible(tester, find.text('Speichern'));
    expect(saved.single.startAt, DateTime(2026, 11, 20, 10));
    expect(saved.single.flyerCount, isNull);
  });

  testWidgets('cannot be saved overlapping another Termin of the stand, and says which', (tester) async {
    await openEntry(tester, pastEntry, otherEntries: [_entry('6', DateTime(2026, 11, 2, 11))]);

    await tapVisible(tester, find.text('Speichern'));

    expect(saved, isEmpty);
    expect(
      find.text('Dieser Termin überschneidet sich mit dem Termin am 02.11.2026 von 11:00 bis 13:00 Uhr.'),
      findsOneWidget,
    );
    expect(isOpen(), isTrue);
  });

  testWidgets('another Termin on the same day that does not overlap is fine', (tester) async {
    await openEntry(tester, pastEntry, otherEntries: [_entry('6', DateTime(2026, 11, 2, 12))]);

    await tapVisible(tester, find.text('Speichern'));

    expect(saved, hasLength(1));
  });

  testWidgets('deleting asks first, naming the Termin', (tester) async {
    await openEntry(tester, pastEntry);

    await tapVisible(tester, find.text('Termin löschen'));

    expect(find.text('Termin löschen?'), findsOneWidget);
    expect(
      find.text(
        'Möchtest du den Termin am 02.11.2026 von 10:00 bis 12:00 Uhr wirklich löschen? '
        'Seine verteilten Flyer werden aus der Summe entfernt.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(deleted, ['7']);
    expect(isOpen(), isFalse);
  });

  testWidgets('cancelling the delete keeps the Termin', (tester) async {
    await openEntry(tester, pastEntry);

    await tapVisible(tester, find.text('Termin löschen'));
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(deleted, isEmpty);
    expect(isOpen(), isTrue);
  });

  testWidgets('the last Termin offers no delete, only a hint', (tester) async {
    await openEntry(tester, pastEntry, canDelete: false);

    expect(find.text('Termin löschen'), findsNothing);
    expect(find.text(_lastEntryHint), findsOneWidget);
    expect(find.text('Speichern'), findsOneWidget);
  });

  testWidgets('is usable at large font sizes', (tester) async {
    await openEntry(tester, pastEntry, otherEntries: [_entry('6', DateTime(2026, 11, 2, 11))], textScale: 2);

    expect(tester.takeException(), isNull);
    await tapVisible(tester, find.text('Speichern'));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('überschneidet sich'), findsOneWidget);
  });

  group('adding', () {
    late List<StandEntryCreateModel> added;

    /// Opens the add form like the stand detail does ([MapConsumer.showModalEditForm]).
    Future<void> openAdd(WidgetTester tester, {List<StandEntryModel> otherEntries = const []}) async {
      added = [];
      tester.view.physicalSize = const Size(411, 900) * tester.view.devicePixelRatio;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => MapConsumer.showModalEditForm(
                  context,
                  () => StandEntryEdit.add(
                    otherEntries: otherEntries,
                    standName: 'Infostand am S-Bahnhof',
                    onAdd: (entry) async => added.add(entry),
                    now: _now,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    bool isAddOpen() => find.text('Termin hinzufügen').evaluate().isNotEmpty;

    testWidgets('is prefilled with today, ending now rounded to the quarter hour, lasting two hours', (tester) async {
      await openAdd(tester);

      expect(find.text('Termin hinzufügen'), findsOneWidget);
      expect(find.text('Infostand am S-Bahnhof'), findsOneWidget);
      expect(find.text('Mittwoch, 4. November 2026'), findsOneWidget);
      expect(find.text('5:45 PM'), findsOneWidget);
      expect(find.text('7:45 PM'), findsOneWidget);
      expect(tester.widget<TextField>(_flyerCountInput).controller!.text, isEmpty);
    });

    testWidgets('offers no delete and no last-Termin hint', (tester) async {
      await openAdd(tester);

      expect(find.text('Termin löschen'), findsNothing);
      expect(find.text(_lastEntryHint), findsNothing);
      expect(find.text('Speichern'), findsOneWidget);
    });

    testWidgets('saves the new Termin with its flyers and closes', (tester) async {
      await openAdd(tester);

      await tester.enterText(_flyerCountInput, '60');
      await tapVisible(tester, find.text('Speichern'));

      final entry = added.single;
      expect(entry.startAt, DateTime(2026, 11, 4, 17, 45));
      expect(entry.endAt, DateTime(2026, 11, 4, 19, 45));
      expect(entry.flyerCount, 60);
      expect(isAddOpen(), isFalse);
    });

    testWidgets('an empty flyer count is saved as 0', (tester) async {
      await openAdd(tester);

      await tapVisible(tester, find.text('Speichern'));

      expect(added.single.flyerCount, 0);
    });

    testWidgets('cannot be saved overlapping another Termin of the stand, and says which', (tester) async {
      await openAdd(tester, otherEntries: [_entry('6', DateTime(2026, 11, 4, 19))]);

      await tapVisible(tester, find.text('Speichern'));

      expect(added, isEmpty);
      expect(
        find.text('Dieser Termin überschneidet sich mit dem Termin am 04.11.2026 von 19:00 bis 21:00 Uhr.'),
        findsOneWidget,
      );
      expect(isAddOpen(), isTrue);
    });

    testWidgets('a Termin after today has no flyer count', (tester) async {
      await openAdd(tester);

      await tapVisible(tester, find.text('Mittwoch, 4. November 2026'));
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(_flyerCountInput).enabled, isFalse);
      expect(find.text(_futureHint), findsOneWidget);
      await tapVisible(tester, find.text('Speichern'));
      expect(added.single.startAt, DateTime(2026, 11, 20, 17, 45));
      expect(added.single.flyerCount, isNull);
    });
  });
}
