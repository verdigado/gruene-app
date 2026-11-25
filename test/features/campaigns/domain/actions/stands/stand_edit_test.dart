import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_edit.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/multiline_text_input_field.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

StandEntryModel _entry(int day, {int flyerCount = 0}) => StandEntryModel(
  id: '$day',
  startAt: DateTime(2026, 11, day, 10),
  endAt: DateTime(2026, 11, day, 12),
  flyerCount: flyerCount,
);

StandDetailModel _stand({List<StandEntryModel>? entries}) => StandDetailModel(
  id: '4711',
  address: AddressModel(street: 'Goethestraße', houseNumber: '25', zipCode: '10625', city: 'Berlin'),
  location: LatLng(52.52, 13.405),
  name: 'Infostand am S-Bahnhof',
  description: 'Vor dem Bäcker',
  comment: 'Strom vom Kiosk',
  flyerCountTotal: 200,
  entries: entries ?? [_entry(4, flyerCount: 120), _entry(2, flyerCount: 80)],
  photos: const [],
  createdAt: '01.11.2026 10:00',
);

/// The text field inside the input with this label.
Finder _input(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => (w is TextInputField && w.labelText == label) || (w is MultiLineTextInputField && w.labelText == label),
  ),
  matching: find.byType(TextField),
);

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'de_DE';
    await initializeDateFormatting('de_DE');
  });

  late List<StandUpdateModel> saved;
  late List<String> deleted;

  /// Opens the edit view the way the map does ([MapConsumer.showModalEditForm]).
  Future<void> openEdit(WidgetTester tester, StandDetailModel stand, {double textScale = 1}) async {
    saved = [];
    deleted = [];
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
                () => StandEdit(
                  stand: stand,
                  onSave: (update) async => saved.add(update),
                  onDelete: (id) async => deleted.add(id),
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

  bool isOpen() => find.text('Wahlkampfstand bearbeiten').evaluate().isNotEmpty;

  testWidgets('shows the stand fields and its address, but no Termine', (tester) async {
    await openEdit(tester, _stand());

    expect(find.text('Wahlkampfstand bearbeiten'), findsOneWidget);
    expect(tester.widget<TextField>(_input('Name')).controller!.text, 'Infostand am S-Bahnhof');
    expect(tester.widget<TextField>(_input('Beschreibung')).controller!.text, 'Vor dem Bäcker');
    expect(tester.widget<TextField>(_input('Kommentar')).controller!.text, 'Strom vom Kiosk');
    expect(find.text('Goethestraße'), findsOneWidget);
    expect(find.text('Termine'), findsNothing);
    expect(find.textContaining(' Uhr'), findsNothing);
    expect(find.text('Eintrag löschen'), findsOneWidget);
  });

  testWidgets('saves the changed fields and address, keeps the location, and closes', (tester) async {
    final stand = _stand();
    await openEdit(tester, stand);

    await tester.enterText(_input('Name'), '  Infostand am Markt ');
    await tester.enterText(_input('Beschreibung'), '   ');
    await tester.enterText(_input('Hausnr.'), '27');
    await tapVisible(tester, find.text('Speichern'));

    final update = saved.single;
    expect(update.id, '4711');
    expect(update.name, 'Infostand am Markt');
    expect(update.description, isNull);
    expect(update.comment, 'Strom vom Kiosk');
    expect(update.address.street, 'Goethestraße');
    expect(update.address.houseNumber, '27');
    expect(update.location, stand.location);
    expect(update.oldStandDetail, same(stand));
    expect(isOpen(), isFalse);
  });

  testWidgets('does not save without a name and shows why', (tester) async {
    await openEdit(tester, _stand());

    await tester.enterText(_input('Name'), ' ');
    await tapVisible(tester, find.text('Speichern'));

    expect(saved, isEmpty);
    expect(find.text('Bitte gib einen Namen ein.'), findsOneWidget);
    expect(isOpen(), isTrue);
  });

  testWidgets('deleting asks first and names how many Termine are deleted with the stand', (tester) async {
    await openEdit(tester, _stand(entries: [_entry(2), _entry(3), _entry(4)]));

    await tapVisible(tester, find.text('Eintrag löschen'));

    expect(find.text('Eintrag löschen?'), findsOneWidget);
    expect(
      find.text(
        'Möchtest du diesen Wahlkampfstand und alle seine 3 Termine wirklich löschen? '
        'Dies kann nicht rückgängig gemacht werden.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(deleted, ['4711']);
    expect(isOpen(), isFalse);
  });

  testWidgets('deleting a stand with one Termin says so', (tester) async {
    await openEdit(tester, _stand(entries: [_entry(4)]));

    await tapVisible(tester, find.text('Eintrag löschen'));

    expect(find.textContaining('und seinen Termin wirklich löschen?'), findsOneWidget);
  });

  testWidgets('deleting a stand whose Termine were all deleted names none', (tester) async {
    await openEdit(tester, _stand(entries: []));

    await tapVisible(tester, find.text('Eintrag löschen'));

    expect(
      find.text('Möchtest du diesen Wahlkampfstand wirklich löschen? Dies kann nicht rückgängig gemacht werden.'),
      findsOneWidget,
    );
  });

  testWidgets('cancelling the delete keeps the stand and the edit view', (tester) async {
    await openEdit(tester, _stand());

    await tapVisible(tester, find.text('Eintrag löschen'));
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(deleted, isEmpty);
    expect(isOpen(), isTrue);
  });

  testWidgets('the close button closes without saving', (tester) async {
    await openEdit(tester, _stand());

    await tester.enterText(_input('Name'), 'Anderer Name');
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(isOpen(), isFalse);
  });

  testWidgets('the keyboard does not cover the field being edited', (tester) async {
    await openEdit(tester, _stand());
    // tall enough to cover the comment field if the sheet stayed behind the keyboard
    const keyboardHeight = 480.0;
    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getRect(_input('Kommentar')).bottom, greaterThan(screenHeight - keyboardHeight));

    // like on a device: the field gets the focus, then the keyboard opens
    await tester.showKeyboard(_input('Kommentar'));
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight * tester.view.devicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    // Flutter scrolls the line with the cursor into view, here the first line of the field
    final firstLineBottom = tester.getRect(_input('Kommentar')).top + 24;
    expect(firstLineBottom, lessThanOrEqualTo(screenHeight - keyboardHeight));
  });

  testWidgets('is usable at large font sizes', (tester) async {
    await openEdit(tester, _stand(), textScale: 2);

    expect(tester.takeException(), isNull);
    await tapVisible(tester, find.text('Speichern'));
    expect(saved, hasLength(1));
  });
}
