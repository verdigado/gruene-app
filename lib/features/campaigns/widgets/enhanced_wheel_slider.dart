import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/widgets/text_input_field.dart';
import 'package:wheel_slider/wheel_slider.dart';

enum SliderInputRange { numbers0To99, numbers0To999, numbers1To999 }

class EnhancedWheelSlider extends StatefulWidget {
  final String labelText;
  final int initialValue;
  final TextEditingController textController;
  final Color? labelColor;
  final Color? borderColor;
  final Color? sliderColor;
  final Color? actionColor;
  final SliderInputRange sliderInputRange;

  final int sliderInterval;

  const EnhancedWheelSlider({
    super.key,
    required this.labelText,
    this.initialValue = 1,
    this.sliderInterval = 1,
    required this.textController,
    this.labelColor,
    this.borderColor,
    this.sliderColor,
    this.actionColor,
    this.sliderInputRange = SliderInputRange.numbers0To999,
  });

  @override
  State<EnhancedWheelSlider> createState() => _EnhancedWheelSliderState();
}

class _EnhancedWheelSliderState extends State<EnhancedWheelSlider> {
  int _nCurrentValue = 1;

  bool showSlider = true;

  late Color _borderColor;
  late Color _labelColor;
  late Color _sliderColor;
  late Color _actionColor;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _borderColor = widget.borderColor ?? Colors.black;
    _labelColor = widget.labelColor ?? Colors.black;
    _sliderColor = widget.sliderColor ?? Colors.black;
    _actionColor = widget.actionColor ?? Colors.black;

    setState(() {
      _nCurrentValue = widget.initialValue;
      showSlider = (_nCurrentValue % widget.sliderInterval == 0);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              if (!showSlider) {
                final val = int.tryParse(widget.textController.text) ?? _nCurrentValue;

                _nCurrentValue = val;
              }
              showSlider = !showSlider;
            }),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.labelText,
                    style: theme.textTheme.labelMedium?.apply(color: _labelColor, fontWeightDelta: 5),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.edit_outlined, size: 20, color: _sliderColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          _showSliderOrTextInput(theme),
        ],
      ),
    );
  }

  Widget _showSliderOrTextInput(ThemeData theme) {
    final inputHeight = 55.0;
    final iconSize = 30.0;
    if (showSlider) {
      return SizedBox(
        height: inputHeight,
        child: WheelSlider.number(
          perspective: 0.01,
          interval: widget.sliderInterval,
          isInfinite: false,
          totalCount: widget.sliderInputRange.getMaxValue(),
          initValue: _nCurrentValue,
          enableAnimation: false,
          unSelectedNumberStyle: theme.textTheme.labelMedium?.apply(color: _labelColor),
          selectedNumberStyle: theme.textTheme.labelMedium?.apply(
            color: _sliderColor,
            fontWeightDelta: 2,
            fontSizeDelta: 2,
          ),
          currentIndex: _nCurrentValue,
          onValueChanged: (val) {
            setState(() {
              _nCurrentValue = val as int;
              widget.textController.text = _nCurrentValue.toString();
            });
          },
          hapticFeedbackType: HapticFeedbackType.heavyImpact,
        ),
      );
    } else {
      return Container(
        color: ThemeColors.background,
        child: SizedBox(
          height: inputHeight,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () => _changeValue(widget.sliderInterval * -1),
                  child: Icon(Icons.remove_circle_outlined, size: iconSize, color: _actionColor),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: TextInputField(
                  labelText: widget.labelText,
                  textController: widget.textController,
                  inputType: widget.sliderInputRange.getInputFieldType(),
                  selectAllTextOnFocus: true,
                ),
              ),
              SizedBox(width: 6),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () => _changeValue(widget.sliderInterval),
                  child: Icon(Icons.add_circle_outlined, size: iconSize, color: _actionColor),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _changeValue(int increase) {
    final val = int.tryParse(widget.textController.text) ?? _nCurrentValue;
    var newValue = val + increase;

    if (newValue > widget.sliderInputRange.getMaxValue() || newValue < widget.sliderInputRange.getMinValue()) return;

    widget.textController.text = newValue.toString();
    _nCurrentValue = newValue;
  }
}
