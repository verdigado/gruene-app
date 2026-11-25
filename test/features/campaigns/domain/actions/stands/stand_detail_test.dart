import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_detail.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

StandEntryModel _entry(int day, {int flyerCount = 0}) => StandEntryModel(
  id: '$day',
  startAt: DateTime(2026, 11, day, 10),
  endAt: DateTime(2026, 11, day, 12),
  flyerCount: flyerCount,
);

StandDetailModel _stand({
  List<StandEntryModel>? entries,
  int flyerCountTotal = 200,
  String? description,
  String? comment,
  bool isCached = false,
}) => StandDetailModel(
  id: '4711',
  address: AddressModel(street: 'Goethestraße', houseNumber: '25', zipCode: '10625', city: 'Berlin'),
  location: LatLng(52.52, 13.405),
  name: 'Infostand am S-Bahnhof',
  description: description,
  comment: comment,
  flyerCountTotal: flyerCountTotal,
  entries: entries ?? [_entry(4, flyerCount: 120), _entry(2, flyerCount: 80)],
  photos: const [],
  createdAt: '01.11.2026 10:00',
  isCached: isCached,
);

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'de_DE';
    await initializeDateFormatting('de_DE');
  });

  /// The result the detail was closed with, like the map receives it.
  ModalDetailResult? detailResult;
  late List<StandEntryCreateModel> addedEntries;
  late List<StandEntryUpdateModel> savedEntries;
  late List<String> deletedEntryIds;

  /// Shows the detail in a bottom sheet over a page, like the map does.
  Future<void> openDetail(
    WidgetTester tester,
    StandDetailModel stand, {
    double textScale = 1,
    double screenWidth = 411,
  }) async {
    detailResult = null;
    addedEntries = [];
    savedEntries = [];
    deletedEntryIds = [];
    tester.view.physicalSize = Size(screenWidth, 900) * tester.view.devicePixelRatio;
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
              onPressed: () async => detailResult = await showModalBottomSheet<ModalDetailResult>(
                context: context,
                builder: (_) => StandDetail(
                  poi: stand,
                  onAddEntry: (stand, entry) async {
                    addedEntries.add(entry);
                    final added = StandEntryModel(
                      id: 'local-1',
                      startAt: entry.startAt,
                      endAt: entry.endAt,
                      flyerCount: entry.flyerCount ?? 0,
                    );
                    return stand.copyWith(entries: [...stand.entries, added], isCached: true);
                  },
                  onSaveEntry: (stand, entry) async {
                    savedEntries.add(entry);
                    final changed = StandEntryModel(
                      id: entry.entryId,
                      startAt: entry.startAt,
                      endAt: entry.endAt,
                      flyerCount: entry.flyerCount ?? 0,
                    );
                    return stand.copyWith(
                      entries: [for (final e in stand.entries) e.id == entry.entryId ? changed : e],
                      isCached: true,
                    );
                  },
                  onDeleteEntry: (stand, entryId) async {
                    deletedEntryIds.add(entryId);
                    return stand.copyWith(
                      entries: stand.entries.where((e) => e.id != entryId).toList(),
                      isCached: true,
                    );
                  },
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

  testWidgets('shows name, type, address and the flyer total from the API', (tester) async {
    await openDetail(tester, _stand());

    expect(find.text('Infostand am S-Bahnhof'), findsOneWidget);
    expect(find.text('Wahlkampfstand'), findsOneWidget);
    expect(find.text('Goethestraße 25, Berlin'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('shows the provisional total while changes are queued', (tester) async {
    await openDetail(tester, _stand(flyerCountTotal: 50, isCached: true));

    expect(find.text('200'), findsOneWidget);
    expect(find.text('50'), findsNothing);
  });

  testWidgets('shows description and comment only if filled in', (tester) async {
    await openDetail(tester, _stand(description: 'Vor dem Bäcker', comment: '  '));

    expect(find.text('Beschreibung'), findsOneWidget);
    expect(find.text('Vor dem Bäcker'), findsOneWidget);
    expect(find.text('Kommentar'), findsNothing);
  });

  testWidgets('with up to 3 Termine, shows all of them without the year and no range', (tester) async {
    await openDetail(tester, _stand(entries: [_entry(2), _entry(4, flyerCount: 120), _entry(3)]));

    expect(find.text('Mi. 04.11. · 10:00–12:00 Uhr'), findsOneWidget);
    expect(find.text('120 Flyer'), findsOneWidget);
    expect(find.text('0 Flyer'), findsNWidgets(2));
    expect(find.textContaining('Alle anzeigen'), findsNothing);
    expect(find.textContaining(' – '), findsNothing);
  });

  testWidgets('with more than 3 Termine, shows the range, the latest 3 and Alle anzeigen', (tester) async {
    await openDetail(
      tester,
      _stand(
        entries: [
          for (final day in [2, 9, 4, 6, 3]) _entry(day),
        ],
      ),
    );

    expect(find.text('02.11.2026 – 09.11.2026'), findsOneWidget);
    final shown = tester.widgetList<Text>(find.textContaining(' Uhr')).map((t) => t.data).toList();
    expect(shown, ['Mo. 09.11. · 10:00–12:00 Uhr', 'Fr. 06.11. · 10:00–12:00 Uhr', 'Mi. 04.11. · 10:00–12:00 Uhr']);
    expect(find.text('Alle anzeigen (5)'), findsOneWidget);
  });

  testWidgets('Alle anzeigen shows all Termine with the year, newest first', (tester) async {
    await openDetail(
      tester,
      _stand(
        entries: [
          for (final day in [2, 9, 4, 6, 3]) _entry(day),
        ],
      ),
    );

    await tester.ensureVisible(find.text('Alle anzeigen (5)'));
    await tester.tap(find.text('Alle anzeigen (5)'));
    await tester.pumpAndSettle();

    final shown = tester.widgetList<Text>(find.textContaining('.2026 · ')).map((t) => t.data!.substring(0, 14));
    expect(shown, ['Mo. 09.11.2026', 'Fr. 06.11.2026', 'Mi. 04.11.2026', 'Di. 03.11.2026', 'Mo. 02.11.2026']);
  });

  testWidgets('the close button is centered on the name', (tester) async {
    await openDetail(tester, _stand());

    final closeCenter = tester.getCenter(find.byIcon(Icons.close)).dy;
    final nameCenter = tester.getCenter(find.text('Infostand am S-Bahnhof')).dy;
    expect(closeCenter, moreOrLessEquals(nameCenter, epsilon: 1));
  });

  testWidgets('Bearbeiten closes the detail and asks the map to open the edit view', (tester) async {
    await openDetail(tester, _stand());

    await tester.tap(find.text('Bearbeiten'));
    await tester.pumpAndSettle();

    expect(find.text('Infostand am S-Bahnhof'), findsNothing);
    expect(detailResult, ModalDetailResult.edit);
  });

  testWidgets('the close button closes the detail', (tester) async {
    await openDetail(tester, _stand());

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Infostand am S-Bahnhof'), findsNothing);
  });

  testWidgets('is usable at large font sizes, also with many Termine', (tester) async {
    await openDetail(
      tester,
      _stand(
        entries: [for (var day = 1; day <= 20; day++) _entry(day)],
        description: 'Vor dem Bäcker, gegenüber vom Eingang zum S-Bahnhof',
      ),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Alle anzeigen (20)'), 100, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Alle anzeigen (20)'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('Termine', () {
    Finder flyerCountInput() => find.descendant(
      of: find.byWidgetPredicate((w) => w is TextInputField && w.labelText == 'Verteilte Flyer (optional)'),
      matching: find.byType(TextField),
    );

    Future<void> tapVisible(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> deleteOpenEntry(WidgetTester tester) async {
      await tapVisible(tester, find.text('Termin löschen'));
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
    }

    testWidgets('each Termin has a chevron to show it can be edited', (tester) async {
      await openDetail(tester, _stand());

      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    testWidgets('tapping a Termin opens it for editing', (tester) async {
      await openDetail(tester, _stand());

      await tapVisible(tester, find.text('Mi. 04.11. · 10:00–12:00 Uhr'));

      expect(find.text('Termin bearbeiten'), findsOneWidget);
      expect(find.text('Termin löschen'), findsOneWidget);
    });

    testWidgets('a saved Termin shows its new values, and the detail stays open', (tester) async {
      await openDetail(tester, _stand());

      await tapVisible(tester, find.text('Mi. 04.11. · 10:00–12:00 Uhr'));
      await tester.enterText(flyerCountInput(), '150');
      await tapVisible(tester, find.text('Speichern'));

      expect(savedEntries.single.flyerCount, 150);
      expect(find.text('Termin bearbeiten'), findsNothing);
      expect(find.text('Infostand am S-Bahnhof'), findsOneWidget);
      expect(find.text('150 Flyer'), findsOneWidget);
      // the provisional total: 150 + 80
      expect(find.text('230'), findsOneWidget);
    });

    testWidgets('a deleted Termin is gone from the detail', (tester) async {
      await openDetail(tester, _stand(entries: [_entry(2), _entry(3), _entry(4)]));

      await tapVisible(tester, find.text('Mi. 04.11. · 10:00–12:00 Uhr'));
      await deleteOpenEntry(tester);

      expect(deletedEntryIds, ['4']);
      expect(find.text('Mi. 04.11. · 10:00–12:00 Uhr'), findsNothing);
      expect(find.text('Infostand am S-Bahnhof'), findsOneWidget);
    });

    testWidgets('the only Termin of a stand cannot be deleted', (tester) async {
      await openDetail(tester, _stand(entries: [_entry(4)]));

      await tapVisible(tester, find.text('Mi. 04.11. · 10:00–12:00 Uhr'));

      expect(find.text('Termin löschen'), findsNothing);
      expect(find.textContaining('Der einzige Termin eines Stands kann nicht gelöscht werden.'), findsOneWidget);
    });

    testWidgets('Termine can be edited in the full list, which shows the change', (tester) async {
      await openDetail(
        tester,
        _stand(
          entries: [
            for (final day in [2, 9, 4, 6, 3]) _entry(day),
          ],
        ),
      );

      await tapVisible(tester, find.text('Alle anzeigen (5)'));
      await tapVisible(tester, find.text('Mo. 02.11.2026 · 10:00–12:00 Uhr'));
      await deleteOpenEntry(tester);

      expect(deletedEntryIds, ['2']);
      expect(find.text('Mo. 02.11.2026 · 10:00–12:00 Uhr'), findsNothing);
      expect(find.text('Di. 03.11.2026 · 10:00–12:00 Uhr'), findsOneWidget);
    });

    testWidgets('a Termin change is made on the stand as already changed', (tester) async {
      await openDetail(tester, _stand(entries: [_entry(2), _entry(3), _entry(4)]));

      await tapVisible(tester, find.text('Mi. 04.11. · 10:00–12:00 Uhr'));
      await deleteOpenEntry(tester);
      await tapVisible(tester, find.text('Di. 03.11. · 10:00–12:00 Uhr'));
      await deleteOpenEntry(tester);

      expect(deletedEntryIds, ['4', '3']);
      expect(find.textContaining(' Uhr'), findsOneWidget);
      // the remaining Termin is the last one of the stand
      await tapVisible(tester, find.text('Mo. 02.11. · 10:00–12:00 Uhr'));
      expect(find.text('Termin löschen'), findsNothing);
    });
  });

  group('Termin hinzufügen', () {
    Finder addButton() => find.widgetWithText(TextButton, 'Termin hinzufügen');

    Finder flyerCountInput() => find.descendant(
      of: find.byWidgetPredicate((w) => w is TextInputField && w.labelText == 'Verteilte Flyer (optional)'),
      matching: find.byType(TextField),
    );

    Future<void> tapVisible(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    testWidgets('is offered right of the title of the Termin list', (tester) async {
      // the test font draws every character as a square, much wider than on a device
      await openDetail(tester, _stand(), screenWidth: 600);

      expect(addButton(), findsOneWidget);
      expect(find.descendant(of: addButton(), matching: find.byIcon(Icons.add)), findsOneWidget);
      final title = tester.getRect(find.text('Termine'));
      final button = tester.getRect(addButton());
      expect(button.left, greaterThan(title.right));
      expect(button.center.dy, moreOrLessEquals(title.center.dy, epsilon: 1));
    });

    testWidgets('opens the add form, without delete', (tester) async {
      await openDetail(tester, _stand());

      await tapVisible(tester, addButton());

      // the title of the form; the button stays in the detail below
      expect(find.text('Termin hinzufügen'), findsNWidgets(2));
      expect(find.text('Termin löschen'), findsNothing);
      expect(find.textContaining('Der einzige Termin'), findsNothing);
    });

    testWidgets('a new Termin shows in the list and counts in the total, and the detail stays open', (tester) async {
      await openDetail(tester, _stand());

      await tapVisible(tester, addButton());
      await tester.enterText(flyerCountInput(), '30');
      await tapVisible(tester, find.text('Speichern'));

      expect(addedEntries.single.flyerCount, 30);
      expect(find.text('Infostand am S-Bahnhof'), findsOneWidget);
      expect(find.text('30 Flyer'), findsOneWidget);
      // the provisional total: 120 + 80 + 30
      expect(find.text('230'), findsOneWidget);
    });

    testWidgets('the full Termin list offers it as well and shows the new Termin', (tester) async {
      await openDetail(
        tester,
        _stand(
          entries: [
            for (final day in [2, 9, 4, 6, 3]) _entry(day),
          ],
        ),
      );

      await tapVisible(tester, find.text('Alle anzeigen (5)'));
      expect(addButton(), findsNWidgets(2)); // in the detail below and in the full list
      await tapVisible(tester, addButton().last);
      await tester.enterText(flyerCountInput(), '30');
      await tapVisible(tester, find.text('Speichern'));

      expect(addedEntries, hasLength(1));
      expect(find.text('30 Flyer'), findsNWidgets(2)); // in the full list and in the latest 3 of the detail
    });

    testWidgets('is usable at large font sizes', (tester) async {
      await openDetail(tester, _stand(), textScale: 2);

      expect(tester.takeException(), isNull);
      await tapVisible(tester, addButton());
      expect(tester.takeException(), isNull);
      expect(find.text('Speichern'), findsOneWidget);
    });
  });
}
