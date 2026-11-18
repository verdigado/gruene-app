import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_create_model.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/widgets/counter_input.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/screens/doors_add_screen.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const _conversations = 'Gespräche (inkl. Material)';
const _materialOnly = 'Material ohne Gespräch';

/// The campaign name in the header is not part of these tests, so it never loads.
class _FakeCampaignApiService extends Fake implements CampaignApiService {
  @override
  Future<Campaign> getCampaign(String campaignId) => Completer<Campaign>().future;
}

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageKeys.activeCampaigns: jsonEncode({'recentSelectedCampaignId': 'campaign-1'}),
    });
    GetIt.I.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
    final appSettings = AppSettings();
    await appSettings.campaign.init();
    GetIt.I.registerSingleton<AppSettings>(appSettings);
    GetIt.I.registerSingleton<CampaignApiService>(_FakeCampaignApiService());
  });

  tearDown(() => GetIt.I.reset());

  /// Opens the add screen as a page, like the map does, and returns a getter for the value it closes with.
  Future<DoorCreateModel? Function()> openAddScreen(WidgetTester tester, {double textScale = 1}) async {
    DoorCreateModel? result;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push(
                MaterialPageRoute<DoorCreateModel>(
                  builder: (_) => Scaffold(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    body: SingleChildScrollView(
                      child: DoorsAddScreen(
                        location: LatLng(52.52, 13.405),
                        address: AddressModel(
                          street: 'Schillerpromenade',
                          houseNumber: '1C',
                          zipCode: '12459',
                          city: 'Berlin',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => result;
  }

  Finder counter(String label) => find.widgetWithText(CounterInput, label);
  Finder counterField(String label) => find.descendant(of: counter(label), matching: find.byType(TextField));
  String counterValue(WidgetTester tester, String label) =>
      tester.widget<TextField>(counterField(label)).controller!.text;

  Future<void> tapButton(WidgetTester tester, String tooltip) async {
    await tester.ensureVisible(find.byTooltip(tooltip));
    await tester.tap(find.byTooltip(tooltip));
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the new title and both counters, conversations first', (tester) async {
    await openAddScreen(tester);

    expect(find.text('Haustürgespräche eintragen'), findsOneWidget);
    expect(counter(_conversations), findsOneWidget);
    expect(counter(_materialOnly), findsOneWidget);
    expect(tester.getTopLeft(counter(_conversations)).dy, lessThan(tester.getTopLeft(counter(_materialOnly)).dy));
  });

  testWidgets('no longer shows the old labels and the hint', (tester) async {
    await openAddScreen(tester);

    expect(find.textContaining('geöffnete', findRichText: true), findsNothing);
    expect(find.textContaining('Geöffnete'), findsNothing);
    expect(find.textContaining('Ungeöffnete'), findsNothing);
    expect(find.textContaining('Bitte trage'), findsNothing);
  });

  testWidgets('starts with 1 conversation and 0 material only', (tester) async {
    await openAddScreen(tester);

    expect(counterValue(tester, _conversations), '1');
    expect(counterValue(tester, _materialOnly), '0');
  });

  testWidgets('saves the starting values with address and campaign', (tester) async {
    final result = await openAddScreen(tester);

    await save(tester);

    final door = result()!;
    expect(door.conversations, 1);
    expect(door.materialOnly, 0);
    expect(door.campaignId, 'campaign-1');
    expect(door.address.street, 'Schillerpromenade');
    expect(door.address.houseNumber, '1C');
    expect(door.location, LatLng(52.52, 13.405));
  });

  testWidgets('saves the values set with − / +', (tester) async {
    final result = await openAddScreen(tester);

    await tapButton(tester, '$_conversations erhöhen');
    await tapButton(tester, '$_conversations erhöhen');
    await tapButton(tester, '$_materialOnly erhöhen');
    await save(tester);

    expect(result()!.conversations, 3);
    expect(result()!.materialOnly, 1);
  });

  testWidgets('saves a typed value', (tester) async {
    final result = await openAddScreen(tester);

    await tester.enterText(counterField(_materialOnly), '12');
    await save(tester);

    expect(result()!.materialOnly, 12);
  });

  testWidgets('refuses to save with both counts at 0', (tester) async {
    final result = await openAddScreen(tester);

    await tapButton(tester, '$_conversations verringern');
    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    // no pumpAndSettle here: it would run until the toast is gone again
    await tester.pump(const Duration(milliseconds: 500));

    expect(result(), isNull);
    expect(find.byType(DoorsAddScreen), findsOneWidget);
    expect(find.text('Bitte gib mindestens ein Gespräch oder Material ein.'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 10));
  });

  testWidgets('stays usable at a large font size', (tester) async {
    tester.view.physicalSize = const Size(360, 740) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    final result = await openAddScreen(tester, textScale: 2);

    expect(tester.takeException(), isNull, reason: 'no layout overflow');
    await tapButton(tester, '$_materialOnly erhöhen');
    await save(tester);

    expect(result()!.conversations, 1);
    expect(result()!.materialOnly, 1);
  });
}
