import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';

void main() {
  group('NumericRangeFormatter', () {
    final formatter = NumericRangeFormatter(min: 1, max: 999);

    TextEditingValue typed(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    TextEditingValue format(String oldText, String newText) =>
        formatter.formatEditUpdate(typed(oldText), typed(newText));

    test('keeps values within the range', () {
      expect(format('1', '12'), typed('12'));
      expect(format('99', '999'), typed('999'));
      expect(format('', '1'), typed('1'));
    });

    test('allows an empty field', () {
      expect(format('5', ''), typed(''));
    });

    test('rejects non-numeric input by keeping the old value', () {
      expect(format('5', '5a'), typed('5'));
      expect(format('5', '-'), typed('5'));
      expect(format('5', '5.5'), typed('5'));
    });

    test('clamps values above the maximum and moves the cursor to the end', () {
      expect(format('500', '5000'), typed('999'));
    });

    test('clamps values below the minimum and moves the cursor to the end', () {
      expect(format('', '0'), typed('1'));
      expect(format('', '-12'), typed('1'));
    });
  });

  group('TextInputField', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    Future<void> pumpField(
      WidgetTester tester, {
      InputFieldType inputType = InputFieldType.string,
      bool selectAllTextOnFocus = false,
      Color? borderColor,
      double? width,
    }) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TextInputField(
              labelText: 'Hausnr.',
              textController: controller,
              inputType: inputType,
              selectAllTextOnFocus: selectAllTextOnFocus,
              borderColor: borderColor,
              width: width,
            ),
          ),
        ),
      ),
    );

    TextField textField(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField));
    BoxDecoration decoration(WidgetTester tester) =>
        tester
                .widget<Container>(
                  find.descendant(of: find.byType(TextInputField), matching: find.byType(Container)).first,
                )
                .decoration!
            as BoxDecoration;

    testWidgets('shows the label and the text of the controller', (tester) async {
      controller.text = '1C';
      await pumpField(tester);

      expect(find.text('Hausnr.'), findsOneWidget);
      expect(find.text('1C'), findsOneWidget);
    });

    testWidgets('writes typed text to the controller', (tester) async {
      await pumpField(tester);

      await tester.enterText(find.byType(TextField), 'Schillerpromenade 1C');

      expect(controller.text, 'Schillerpromenade 1C');
    });

    testWidgets('string input accepts any text with the default keyboard', (tester) async {
      await pumpField(tester);

      await tester.enterText(find.byType(TextField), 'a-1.5');

      expect(controller.text, 'a-1.5');
      expect(textField(tester).keyboardType, TextInputType.text);
    });

    testWidgets('numbers input accepts digits only', (tester) async {
      await pumpField(tester, inputType: InputFieldType.numbers);

      await tester.enterText(find.byType(TextField), '12a-3');

      expect(controller.text, '123');
    });

    for (final (inputType, tooHigh, max, tooLow, min) in [
      (InputFieldType.numbers0To99, '150', '99', '-1', '0'),
      (InputFieldType.numbers0To999, '5000', '999', '-1', '0'),
      (InputFieldType.numbers1To999, '5000', '999', '0', '1'),
    ]) {
      testWidgets('${inputType.name} clamps to $min..$max', (tester) async {
        await pumpField(tester, inputType: inputType);

        await tester.enterText(find.byType(TextField), tooHigh);
        expect(controller.text, max);

        await tester.enterText(find.byType(TextField), tooLow);
        expect(controller.text, min);
      });
    }

    for (final inputType in InputFieldType.values.where((type) => type != InputFieldType.string)) {
      testWidgets('${inputType.name} shows the number keyboard', (tester) async {
        await pumpField(tester, inputType: inputType);

        expect(textField(tester).keyboardType, TextInputType.number);
      });
    }

    testWidgets('selects all text on focus when enabled', (tester) async {
      controller.text = '123';
      await pumpField(tester, selectAllTextOnFocus: true);

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 3));
    });

    testWidgets('does not select all text on focus by default', (tester) async {
      controller.text = '123';
      await pumpField(tester);

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(controller.selection.isCollapsed, isTrue);
    });

    testWidgets('draws a border only when a border color is given', (tester) async {
      await pumpField(tester);
      expect(decoration(tester).border, isNull);

      await pumpField(tester, borderColor: Colors.red);
      expect(decoration(tester).border, Border.all(color: Colors.red, width: 1));
    });

    testWidgets('uses the given width', (tester) async {
      await pumpField(tester, width: 120);

      expect(tester.getSize(find.byType(TextInputField)).width, 120);
    });
  });
}
