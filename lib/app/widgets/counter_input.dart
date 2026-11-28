import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// A count with − / + buttons and the number in between, which can also be typed.
///
/// [controller] holds the value as text, an empty field counts as [min].
/// [foregroundColor] colors the label and the buttons, so the counter works on light and dark backgrounds.
class CounterInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final int min;
  final int max;
  final Color? foregroundColor;

  const CounterInput({
    super.key,
    required this.label,
    required this.controller,
    this.min = 0,
    this.max = 999,
    this.foregroundColor,
  });

  @override
  State<CounterInput> createState() => _CounterInputState();
}

class _CounterInputState extends State<CounterInput> {
  final _focusNode = FocusNode();

  int get _value => int.tryParse(widget.controller.text) ?? widget.min;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onValueChanged);
    _focusNode.addListener(_selectAllOnFocus);
  }

  @override
  void didUpdateWidget(CounterInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onValueChanged);
      widget.controller.addListener(_onValueChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onValueChanged);
    _focusNode.dispose();
    super.dispose();
  }

  // rebuild, so the buttons get enabled or disabled
  void _onValueChanged() => setState(() {});

  void _selectAllOnFocus() {
    if (!_focusNode.hasFocus) return;
    widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length);
  }

  void _changeValue(int delta) {
    final newValue = (_value + delta).clamp(widget.min, widget.max);
    widget.controller.text = newValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = widget.foregroundColor ?? theme.colorScheme.primary;
    final buttonStyle = IconButton.styleFrom(
      foregroundColor: foregroundColor,
      side: BorderSide(color: foregroundColor, width: 1.5),
      disabledForegroundColor: foregroundColor.withValues(alpha: 0.4),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.textTheme.labelLarge?.apply(color: foregroundColor)),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton.outlined(
              style: buttonStyle,
              tooltip: t.common.counter.decrease(label: widget.label),
              icon: const Icon(Icons.remove),
              onPressed: _value > widget.min ? () => _changeValue(-1) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [NumericRangeFormatter(min: widget.min, max: widget.max)],
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.apply(color: ThemeColors.text),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ThemeColors.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ThemeColors.grey200),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              style: buttonStyle,
              tooltip: t.common.counter.increase(label: widget.label),
              icon: const Icon(Icons.add),
              onPressed: _value < widget.max ? () => _changeValue(1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
