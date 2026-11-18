import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/address_field_detail.dart';

const _longStreet = 'Kaiserslauterer Straße';
const _houseNumber = '25A';

void main() {
  Future<void> pumpAddress(WidgetTester tester, Widget Function(Widget address) wrap) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(textTheme: const TextTheme(labelSmall: TextStyle(fontSize: 10, height: 1.3))),
      home: Scaffold(
        body: Center(
          child: wrap(const AddressFieldDetail(street: _longStreet, houseNumber: _houseNumber)),
        ),
      ),
    ),
  );

  RenderParagraph street(WidgetTester tester) => tester.renderObject<RenderParagraph>(find.text(_longStreet));
  double fullWidthOf(WidgetTester tester, String text) {
    final style = DefaultTextStyle.of(tester.element(find.text(text))).style
        .merge(tester.widget<Text>(find.text(text)).style);
    return (TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout()).width;
  }

  testWidgets('shows the full street when there is room', (tester) async {
    await pumpAddress(tester, (address) => SizedBox(width: 500, child: address));

    expect(street(tester).didExceedMaxLines, isFalse);
    expect(tester.getSize(find.text(_longStreet)).width, moreOrLessEquals(fullWidthOf(tester, _longStreet)));
  });

  testWidgets('right-aligns street and house number', (tester) async {
    await pumpAddress(tester, (address) => SizedBox(width: 500, child: address));

    expect(tester.getTopRight(find.text(_houseNumber)).dx, tester.getTopRight(find.byType(AddressFieldDetail)).dx);
  });

  testWidgets('uses all the remaining width for the street and ends it with an ellipsis', (tester) async {
    await pumpAddress(tester, (address) => SizedBox(width: 150, child: address));

    final houseNumberWidth = tester.getSize(find.text(_houseNumber)).width;
    expect(street(tester).didExceedMaxLines, isTrue, reason: 'ellipsis');
    expect(tester.getSize(find.text(_longStreet)).width, 150 - 3 - houseNumberWidth, reason: 'all remaining width');
    expect(street(tester).text.toPlainText(), _longStreet, reason: 'no line break, one line with ellipsis');
    expect(tester.getSize(find.text(_longStreet)).height, tester.getSize(find.text(_houseNumber)).height);
  });

  testWidgets('always shows the full house number', (tester) async {
    await pumpAddress(tester, (address) => SizedBox(width: 80, child: address));

    expect(tester.getSize(find.text(_houseNumber)).width, moreOrLessEquals(fullWidthOf(tester, _houseNumber)));
    expect(tester.takeException(), isNull, reason: 'no layout overflow');
  });

  testWidgets('does not widen a parent that sizes itself to its content', (tester) async {
    await pumpAddress(
      tester,
      (address) => IntrinsicWidth(child: Column(children: [address, const SizedBox(width: 120, height: 10)])),
    );

    expect(tester.getSize(find.byType(AddressFieldDetail)).width, 120, reason: 'width comes from the other content');
    expect(street(tester).didExceedMaxLines, isTrue, reason: 'the street gets an ellipsis instead');
    expect(tester.takeException(), isNull);
  });
}
