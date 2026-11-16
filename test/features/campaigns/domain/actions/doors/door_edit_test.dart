import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_update_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/widgets/counter_input.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/screens/door_edit.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/delete_and_save_widget.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const _conversations = 'Gespräche (inkl. Material)';
const _materialOnly = 'Material ohne Gespräch';

/// A door as saved before, e.g. by an older app version
final _storedDoor = DoorDetailModel(
  id: '4711',
  address: AddressModel(street: 'Schillerpromenade', houseNumber: '1C', zipCode: '12459', city: 'Berlin'),
  conversations: 4,
  materialOnly: 2,
  createdAt: '01.11.2026 10:00',
  location: LatLng(52.52, 13.405),
);

void main() {
  /// Opens the edit form in a bottom sheet, like the map does, and returns the updates passed to onSave.
  Future<List<DoorUpdateModel>> openEditSheet(WidgetTester tester, {double textScale = 1}) async {
    final savedUpdates = <DoorUpdateModel>[];
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => SingleChildScrollView(
                child: DoorEdit(
                  door: _storedDoor,
                  onSave: (update) async => savedUpdates.add(update),
                  onDelete: (_) async {},
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return savedUpdates;
  }

  Finder counter(String label) => find.widgetWithText(CounterInput, label);
  Finder counterField(String label) => find.descendant(of: counter(label), matching: find.byType(TextField));
  String counterValue(WidgetTester tester, String label) =>
      tester.widget<TextField>(counterField(label)).controller!.text;
  Finder saveButton() => find.descendant(of: find.byType(DeleteAndSaveWidget), matching: find.text('Speichern'));

  Future<void> tapButton(WidgetTester tester, String tooltip) async {
    await tester.ensureVisible(find.byTooltip(tooltip));
    await tester.tap(find.byTooltip(tooltip));
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(saveButton());
    await tester.tap(saveButton());
  }

  testWidgets('shows the new title and both counters, conversations first', (tester) async {
    await openEditSheet(tester);

    expect(find.text('Haustürgespräche bearbeiten'), findsOneWidget);
    expect(tester.getTopLeft(counter(_conversations)).dy, lessThan(tester.getTopLeft(counter(_materialOnly)).dy));
    expect(find.textContaining('Türen'), findsNothing);
  });

  testWidgets('opens an existing entry with its stored values', (tester) async {
    await openEditSheet(tester);

    expect(counterValue(tester, _conversations), '4');
    expect(counterValue(tester, _materialOnly), '2');
  });

  testWidgets('saves an unchanged entry back unchanged', (tester) async {
    final savedUpdates = await openEditSheet(tester);

    await tapSave(tester);
    await tester.pumpAndSettle();

    final update = savedUpdates.single;
    expect(update.id, '4711');
    expect(update.conversations, 4);
    expect(update.materialOnly, 2);
    expect(update.address.toJson(), _storedDoor.address.toJson());
    expect(update.location, _storedDoor.location);
    expect(update.oldDoorDetail, same(_storedDoor));
    expect(find.byType(DoorEdit), findsNothing, reason: 'the sheet closes after saving');
  });

  testWidgets('saves the values changed with − / +', (tester) async {
    final savedUpdates = await openEditSheet(tester);

    await tapButton(tester, '$_conversations verringern');
    await tapButton(tester, '$_materialOnly erhöhen');
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(savedUpdates.single.conversations, 3);
    expect(savedUpdates.single.materialOnly, 3);
  });

  testWidgets('refuses to save with both counts at 0', (tester) async {
    final savedUpdates = await openEditSheet(tester);

    await tester.enterText(counterField(_conversations), '0');
    await tester.enterText(counterField(_materialOnly), '0');
    await tapSave(tester);
    // no pumpAndSettle here: it would run until the toast is gone again
    await tester.pump(const Duration(milliseconds: 500));

    expect(savedUpdates, isEmpty);
    expect(find.byType(DoorEdit), findsOneWidget);
    expect(find.text('Bitte gib mindestens ein Gespräch oder Material ein.'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 10));
  });

  testWidgets('stays usable at a large font size', (tester) async {
    tester.view.physicalSize = const Size(360, 740) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    final savedUpdates = await openEditSheet(tester, textScale: 2);

    expect(tester.takeException(), isNull, reason: 'no layout overflow');
    await tapButton(tester, '$_materialOnly erhöhen');
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(savedUpdates.single.materialOnly, 3);
  });
}
