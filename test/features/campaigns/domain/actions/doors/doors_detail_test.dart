import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_detail_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/screens/doors_detail.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/map_popover.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const _conversations = 'Gespräche (inkl. Material)';
const _materialOnly = 'Material ohne Gespräch';
const _screenWidth = 411.0;

DoorDetailModel _door({String street = 'Schillerpromenade', int conversations = 3, int materialOnly = 12}) =>
    DoorDetailModel(
      id: '4711',
      address: AddressModel(street: street, houseNumber: '1C', zipCode: '12459', city: 'Berlin'),
      conversations: conversations,
      materialOnly: materialOnly,
      createdAt: '01.11.2026 10:00',
      location: LatLng(52.52, 13.405),
    );

void main() {
  /// Shows the detail in a map popover sized to its content, like the map does,
  /// on a 411 dp wide screen (a common 1080 px phone).
  Future<void> pumpDetail(WidgetTester tester, DoorDetailModel door, {double textScale = 1}) async {
    tester.view.physicalSize = const Size(_screenWidth, 900) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        // same size and line height as the app's labelSmall (PT Sans is loaded at runtime, so not available here)
        theme: ThemeData(textTheme: const TextTheme(labelSmall: TextStyle(fontSize: 10, height: 1.3))),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Stack(
            children: [
              MapPopover(
                anchor: const Offset(_screenWidth / 2, 600),
                onClose: () {},
                onEdit: () {},
                child: DoorsDetail(poi: door),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double lineHeight(WidgetTester tester) => tester.getSize(find.text('999').first).height;
  Rect popoverRect(WidgetTester tester) =>
      tester.getRect(find.descendant(of: find.byType(FractionalTranslation), matching: find.byType(Column)).first);

  testWidgets('shows both counts with the new labels, conversations first', (tester) async {
    await pumpDetail(tester, _door());

    expect(find.text(_conversations), findsOneWidget);
    expect(find.text(_materialOnly), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(tester.getTopLeft(find.text(_conversations)).dy, lessThan(tester.getTopLeft(find.text(_materialOnly)).dy));
  });

  for (final textScale in [1.0, 1.15]) {
    testWidgets('at text scale $textScale the popover is wide enough for one line per label', (tester) async {
      await pumpDetail(tester, _door(conversations: 999, materialOnly: 999), textScale: textScale);

      expect(tester.takeException(), isNull, reason: 'no layout overflow');
      expect(tester.getSize(find.text(_conversations)).height, lineHeight(tester), reason: 'no line break');
      expect(tester.getSize(find.text(_materialOnly)).height, lineHeight(tester), reason: 'no line break');
    });
  }

  for (final textScale in [1.3, 2.0, 3.0]) {
    testWidgets('shows everything without overflow at text scale $textScale', (tester) async {
      await pumpDetail(
        tester,
        _door(street: 'Karl-Liebknecht-Straße', conversations: 999, materialOnly: 999),
        textScale: textScale,
      );

      expect(tester.takeException(), isNull, reason: 'no layout overflow');
      expect(find.text(_conversations), findsOneWidget);
      expect(find.text(_materialOnly), findsOneWidget);
    });
  }

  testWidgets('a long street does not widen the popover, it ends with an ellipsis', (tester) async {
    await pumpDetail(tester, _door(street: 'Am Hügel'));
    final withShortStreet = popoverRect(tester);
    await pumpDetail(tester, _door(street: 'Kaiserslauterer Straße mit sehr langem Namen'));
    final withLongStreet = popoverRect(tester);

    expect(withLongStreet.width, withShortStreet.width, reason: 'the labels set the width');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the popover grows with the font size, but never beyond the screen', (tester) async {
    await pumpDetail(tester, _door());
    final normal = popoverRect(tester);
    await pumpDetail(tester, _door(), textScale: 1.15);
    final larger = popoverRect(tester);
    await pumpDetail(tester, _door(), textScale: 3);
    final huge = popoverRect(tester);

    expect(larger.width, greaterThan(normal.width));
    expect(larger.height, greaterThan(normal.height));
    expect(huge.width, lessThanOrEqualTo(_screenWidth - 32), reason: 'popover keeps a margin to the screen edges');
  });
}
