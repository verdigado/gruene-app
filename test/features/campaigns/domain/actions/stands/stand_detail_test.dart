import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_detail.dart';
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

  /// Shows the detail in a bottom sheet over a page, like the map does.
  Future<void> openDetail(WidgetTester tester, StandDetailModel stand, {double textScale = 1}) async {
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
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => StandDetail(poi: stand),
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
    expect(find.text('Alle anzeigen'), findsNothing);
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
    expect(find.text('Alle anzeigen'), findsOneWidget);
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

    await tester.ensureVisible(find.text('Alle anzeigen'));
    await tester.tap(find.text('Alle anzeigen'));
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
    await tester.scrollUntilVisible(find.text('Alle anzeigen'), 100, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Alle anzeigen'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
