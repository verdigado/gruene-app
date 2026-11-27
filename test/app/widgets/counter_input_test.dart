import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/widgets/counter_input.dart';

const _label = 'Gespräche (inkl. Material)';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pumpCounter(WidgetTester tester, {String initial = '0', int max = 999, double textScale = 1}) async {
    controller.text = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: const Size(320, 640), textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CounterInput(label: _label, controller: controller, max: max),
            ),
          ),
        ),
      ),
    );
  }

  Finder decreaseButton() => find.byTooltip('$_label verringern');
  Finder increaseButton() => find.byTooltip('$_label erhöhen');
  bool isEnabled(WidgetTester tester, Finder button) =>
      tester.widget<IconButton>(find.ancestor(of: button, matching: find.byType(IconButton)).first).onPressed != null;

  testWidgets('shows the label and the value of the controller', (tester) async {
    await pumpCounter(tester, initial: '3');

    expect(find.text(_label), findsOneWidget);
    expect(find.widgetWithText(TextField, '3'), findsOneWidget);
  });

  testWidgets('+ increases the value', (tester) async {
    await pumpCounter(tester, initial: '1');

    await tester.tap(increaseButton());
    await tester.pump();

    expect(controller.text, '2');
  });

  testWidgets('− decreases the value and stops at 0', (tester) async {
    await pumpCounter(tester, initial: '1');

    await tester.tap(decreaseButton());
    await tester.pump();
    expect(controller.text, '0');
    expect(isEnabled(tester, decreaseButton()), isFalse);

    await tester.tap(decreaseButton(), warnIfMissed: false);
    await tester.pump();
    expect(controller.text, '0');
  });

  testWidgets('+ stops at the maximum', (tester) async {
    await pumpCounter(tester, initial: '998', max: 999);

    await tester.tap(increaseButton());
    await tester.pump();

    expect(controller.text, '999');
    expect(isEnabled(tester, increaseButton()), isFalse);
  });

  testWidgets('an empty field counts as 0', (tester) async {
    await pumpCounter(tester, initial: '');

    expect(isEnabled(tester, decreaseButton()), isFalse);
    await tester.tap(increaseButton());
    await tester.pump();

    expect(controller.text, '1');
  });

  testWidgets('tapping the number allows typing a new value', (tester) async {
    await pumpCounter(tester, initial: '1');

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();

    expect(controller.text, '12');
    expect(isEnabled(tester, decreaseButton()), isTrue);
  });

  testWidgets('selects the number on focus, so typing replaces it', (tester) async {
    await pumpCounter(tester, initial: '42');

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 2));
  });

  testWidgets('accepts only digits within the range', (tester) async {
    await pumpCounter(tester, initial: '5');

    await tester.enterText(find.byType(TextField), '-');
    expect(controller.text, '5');

    await tester.enterText(find.byType(TextField), 'abc');
    expect(controller.text, '5');

    await tester.enterText(find.byType(TextField), '5000');
    expect(controller.text, '999');
  });

  testWidgets('follows changes of the controller from outside', (tester) async {
    await pumpCounter(tester, initial: '0');
    expect(isEnabled(tester, decreaseButton()), isFalse);

    controller.text = '4';
    await tester.pump();

    expect(find.widgetWithText(TextField, '4'), findsOneWidget);
    expect(isEnabled(tester, decreaseButton()), isTrue);
  });

  for (final textScale in [1.5, 2.0, 3.0]) {
    testWidgets('stays usable at text scale $textScale on a narrow screen', (tester) async {
      await pumpCounter(tester, initial: '7', textScale: textScale);

      expect(tester.takeException(), isNull, reason: 'no layout overflow');
      await tester.tap(increaseButton());
      await tester.pump();
      expect(controller.text, '8');

      final buttonSize = tester.getSize(find.ancestor(of: increaseButton(), matching: find.byType(IconButton)).first);
      expect(buttonSize.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(buttonSize.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    });
  }
}
