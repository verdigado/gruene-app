import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/photo_carousel.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_add_screen.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/multiline_text_input_field.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const _flyerCount = 'Verteilte Flyer (optional)';
const _futureHint = 'Verteilte Flyer kannst du eintragen, sobald der Termin stattgefunden hat.';

/// The campaign name in the header is not part of these tests, so it never loads.
class _FakeCampaignApiService extends Fake implements CampaignApiService {
  @override
  Future<Campaign> getCampaign(String campaignId) => Completer<Campaign>().future;
}

/// Wednesday, 19:52: the Termin defaults to 17:45 – 19:45 today.
DateTime _now() => DateTime(2026, 11, 4, 19, 52);

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'de_DE';
    await initializeDateFormatting('de_DE');
  });

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

  /// Opens the add screen as a page, like the map does. The getters return whether it was closed and with what.
  Future<({StandCreateModel? Function() result, bool Function() closed})> openAddScreen(
    WidgetTester tester, {
    AddressModel? address,
    double textScale = 1,
  }) async {
    StandCreateModel? result;
    var closed = false;
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
                MaterialPageRoute<StandCreateModel>(
                  builder: (_) => Scaffold(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    // as ContentPage with withScroll: false (MapConsumer.addPOIClicked with scrollAddScreen: false)
                    body: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: StandAddScreen(
                        location: LatLng(52.52, 13.405),
                        address:
                            address ??
                            AddressModel(street: 'Marktplatz', houseNumber: '1', zipCode: '12459', city: 'Berlin'),
                        now: _now,
                      ),
                    ),
                  ),
                ),
              );
              closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return (result: () => result, closed: () => closed);
  }

  Finder textField(String label) =>
      find.descendant(of: find.widgetWithText(TextInputField, label), matching: find.byType(TextField));
  Finder multiLineField(String label) =>
      find.descendant(of: find.widgetWithText(MultiLineTextInputField, label), matching: find.byType(TextField));

  /// Typing scrolls the field into view with an animation; it has to end before scrolling to [text].
  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> pickDay(WidgetTester tester, int day) async {
    await tapText(tester, 'Mittwoch, 4. November 2026');
    await tester.tap(find.text('$day'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the fields in the order of the mockup', (tester) async {
    await openAddScreen(tester);

    // the photos come first, right below the title
    final photoTop = tester.getTopLeft(find.byType(PhotoCarouselEditor)).dy;
    expect(tester.getTopLeft(find.text('Wahlkampfstand eintragen')).dy, lessThan(photoTop));
    expect(tester.getTopLeft(find.text('Name')).dy, greaterThan(photoTop));
    // `Speichern` stays at the bottom of the screen, see below
    final labels = ['Name', 'Beschreibung', 'Ort', 'Datum', 'Von', _flyerCount, 'Kommentar'];
    final tops = [for (final label in labels) tester.getTopLeft(find.text(label).first).dy];
    expect(tops, orderedEquals([...tops]..sort()));
    expect(find.text('Wahlkampfstand eintragen'), findsOneWidget);
  });

  testWidgets('prefills the name with the address and the date with today', (tester) async {
    await openAddScreen(tester);

    expect(tester.widget<TextField>(textField('Name')).controller!.text, 'Marktplatz 1');
    expect(find.text('Mittwoch, 4. November 2026'), findsOneWidget);
  });

  testWidgets('the name follows the address until it is changed', (tester) async {
    await openAddScreen(tester);
    final street = textField('Straße');

    await tester.enterText(street, 'Rathausplatz');
    expect(tester.widget<TextField>(textField('Name')).controller!.text, 'Rathausplatz 1');

    await tester.enterText(textField('Name'), 'Infostand Rathaus');
    await tester.enterText(street, 'Bahnhofstraße');
    expect(tester.widget<TextField>(textField('Name')).controller!.text, 'Infostand Rathaus');
  });

  testWidgets('saves the stand with its first Termin', (tester) async {
    final screen = await openAddScreen(tester);

    await tester.enterText(multiLineField('Beschreibung'), 'Mit Lastenrad');
    await tester.enterText(textField(_flyerCount), '120');
    await tapText(tester, 'Speichern');

    final stand = screen.result()!;
    expect(stand.name, 'Marktplatz 1');
    expect(stand.description, 'Mit Lastenrad');
    expect(stand.comment, isNull);
    expect(stand.address.street, 'Marktplatz');
    expect(stand.location, LatLng(52.52, 13.405));
    expect(stand.campaignId, 'campaign-1');
    expect(stand.firstEntry.startAt, DateTime(2026, 11, 4, 17, 45));
    expect(stand.firstEntry.endAt, DateTime(2026, 11, 4, 19, 45));
    expect(stand.firstEntry.flyerCount, 120);
    expect(stand.imageFileLocations, isEmpty);
  });

  testWidgets('the title and the buttons stay in place while the fields scroll', (tester) async {
    await openAddScreen(tester);
    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final titleTop = tester.getTopLeft(find.text('Wahlkampfstand eintragen')).dy;
    final saveTop = tester.getTopLeft(find.text('Speichern')).dy;
    final nameTop = tester.getTopLeft(find.text('Name')).dy;
    expect(tester.getBottomLeft(find.text('Speichern')).dy, lessThan(screenHeight));

    await tester.drag(find.text('Name'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Wahlkampfstand eintragen')).dy, titleTop);
    expect(tester.getTopLeft(find.text('Speichern')).dy, saveTop);
    expect(tester.getTopLeft(find.text('Name')).dy, lessThan(nameTop));
  });

  testWidgets('without photos, the form shows the logo and the camera button', (tester) async {
    await openAddScreen(tester);

    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
  });

  testWidgets('saves an empty flyer count as 0', (tester) async {
    final screen = await openAddScreen(tester);

    await tapText(tester, 'Speichern');

    expect(screen.result()!.firstEntry.flyerCount, 0);
  });

  testWidgets('without an address the name has to be typed in', (tester) async {
    final screen = await openAddScreen(tester, address: AddressModel());

    await tapText(tester, 'Speichern');

    expect(screen.closed(), isFalse);
    expect(find.text('Bitte gib einen Namen ein.'), findsOneWidget);

    await tester.enterText(textField('Name'), 'Infostand');
    await tester.pump();
    expect(find.text('Bitte gib einen Namen ein.'), findsNothing);
    await tapText(tester, 'Speichern');

    expect(screen.result()!.name, 'Infostand');
    expect(screen.result()!.address.street, isEmpty);
  });

  testWidgets('refuses a name longer than 100 characters', (tester) async {
    final screen = await openAddScreen(tester);

    await tester.enterText(textField('Name'), 'a' * 101);
    await tapText(tester, 'Speichern');

    expect(screen.closed(), isFalse);
    expect(find.text('Höchstens 100 Zeichen.'), findsOneWidget);
  });

  testWidgets('a future date disables the flyer count with a hint', (tester) async {
    final screen = await openAddScreen(tester);

    await pickDay(tester, 25);

    expect(tester.widget<TextField>(textField(_flyerCount)).enabled, isFalse);
    expect(find.text(_futureHint), findsOneWidget);
    await tapText(tester, 'Speichern');
    expect(screen.result()!.firstEntry.startAt, DateTime(2026, 11, 25, 17, 45));
    expect(screen.result()!.firstEntry.flyerCount, isNull);
  });

  testWidgets('a future date clears a typed flyer count after asking', (tester) async {
    await openAddScreen(tester);
    await tester.enterText(textField(_flyerCount), '50');

    await pickDay(tester, 25);
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Abbrechen')));
    await tester.pumpAndSettle();

    expect(find.text('Mittwoch, 4. November 2026'), findsOneWidget);
    expect(tester.widget<TextField>(textField(_flyerCount)).controller!.text, '50');

    await pickDay(tester, 25);
    await tapText(tester, 'Datum übernehmen');

    expect(find.text('Mittwoch, 25. November 2026'), findsOneWidget);
    expect(tester.widget<TextField>(textField(_flyerCount)).controller!.text, isEmpty);
  });

  testWidgets('a past date keeps the flyer count', (tester) async {
    final screen = await openAddScreen(tester);
    await tester.enterText(textField(_flyerCount), '50');

    await pickDay(tester, 2);
    await tapText(tester, 'Speichern');

    expect(screen.result()!.firstEntry.startAt, DateTime(2026, 11, 2, 17, 45));
    expect(screen.result()!.firstEntry.flyerCount, 50);
  });

  testWidgets('leaving without changes closes at once', (tester) async {
    final screen = await openAddScreen(tester);

    await tapText(tester, 'Abbrechen');

    expect(screen.closed(), isTrue);
    expect(screen.result(), isNull);
  });

  testWidgets('leaving with changes asks before discarding', (tester) async {
    final screen = await openAddScreen(tester);
    await tester.enterText(multiLineField('Kommentar'), 'Tisch mitbringen');

    await tapText(tester, 'Abbrechen');
    expect(find.text('Deine Eingaben wurden noch nicht gespeichert. Möchtest du sie verwerfen?'), findsOneWidget);

    await tapText(tester, 'Weiter bearbeiten');
    expect(screen.closed(), isFalse);

    await tapText(tester, 'Abbrechen');
    await tapText(tester, 'Verwerfen');
    expect(screen.closed(), isTrue);
    expect(screen.result(), isNull);
  });

  testWidgets('stays usable at a large font size', (tester) async {
    tester.view.physicalSize = const Size(360, 740) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    final screen = await openAddScreen(tester, textScale: 2);

    expect(tester.takeException(), isNull, reason: 'no layout overflow');
    await tapText(tester, 'Speichern');

    expect(screen.result()!.name, 'Marktplatz 1');
  });
}
