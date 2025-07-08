import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/theme/theme.dart';

class TextInputField extends StatefulWidget {
  final String labelText;

  final double? width;

  final TextEditingController textController;

  final Color? borderColor;

  final InputFieldType inputType;

  final bool selectAllTextOnFocus;

  const TextInputField({
    required this.labelText,
    required this.textController,
    this.width,
    this.borderColor,
    this.inputType = InputFieldType.string,
    this.selectAllTextOnFocus = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? formatters;
    TextInputType? inputType;
    switch (widget.inputType) {
      case InputFieldType.string:
        formatters = null;
        inputType = null;
      case InputFieldType.numbers:
        inputType = TextInputType.number;
        formatters = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
      case InputFieldType.numbers0To99:
        inputType = TextInputType.number;
        formatters = <TextInputFormatter>[NumericRangeFormatter(min: 0, max: 99)];
      case InputFieldType.numbers0To999:
        inputType = TextInputType.number;
        formatters = <TextInputFormatter>[NumericRangeFormatter(min: 0, max: 999)];
      case InputFieldType.numbers1To999:
        inputType = TextInputType.number;
        formatters = <TextInputFormatter>[NumericRangeFormatter(min: 1, max: 999)];
    }
    final theme = Theme.of(context);
    final inputBorder = switch (widget.borderColor) {
      (null) => null,
      (_) => Border.all(color: widget.borderColor!, width: 1),
    };
    return Container(
      width: widget.width,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: inputBorder,
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Focus(
        onFocusChange: (value) {
          if (widget.selectAllTextOnFocus) {
            widget.textController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: widget.textController.value.text.length,
            );
          }
        },
        child: TextFormField(
          controller: widget.textController,
          keyboardType: inputType,
          inputFormatters: formatters,
          style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.text),
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: InputBorder.none,
            labelStyle: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
            floatingLabelStyle: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled),
          ),
        ),
      ),
    );
  }
}

enum InputFieldType { string, numbers, numbers0To99, numbers0To999, numbers1To999 }

class NumericRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  NumericRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newValueNumber = int.tryParse(newValue.text);

    if (newValueNumber == null) {
      return oldValue;
    }

    if (newValueNumber < min) {
      return newValue.copyWith(text: min.toString());
    } else if (newValueNumber > max) {
      return newValue.copyWith(text: max.toString());
    } else {
      return newValue;
    }
  }
}
