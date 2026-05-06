import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:gruene_app/app/theme/theme.dart';

const trackBarHeight = 10.0;
// Implicit flutter_xlider padding: handlerHeight / 2 = 32 / 2 = 16
const trackBarPadding = 16;
// handlerHeight - trackBarHeight / 2 = 32 - 5 = 27
const trackBarTop = 27.0;

class OptionSlider<T> extends StatelessWidget {
  final void Function(T value) update;
  final List<T> values;
  final T value;
  final String Function(T value) getLabel;

  const OptionSlider({
    super.key,
    required this.update,
    required this.values,
    required this.value,
    required this.getLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxIndex = values.length - 1;
    final selectedIndex = values.indexOf(value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth - 2 * trackBarPadding;

        double labelFractionalTranslationOffset(int index) {
          if (index == 0) return 0;
          return index == maxIndex ? -1 : -0.5;
        }

        double hatchMarkPosition(int index) => (trackBarPadding + (index / maxIndex) * trackWidth).round().toDouble();

        return Stack(
          children: [
            FlutterSlider(
              values: [selectedIndex.toDouble()],
              min: 0,
              max: maxIndex.toDouble(),
              onDragging: (handlerIndex, lowerValue, upperValue) => update(values[(lowerValue as double).round()]),
              handlerHeight: 32,
              handler: FlutterSliderHandler(
                decoration: BoxDecoration(),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: BoxBorder.all(color: theme.colorScheme.secondary, width: 3),
                  ),
                ),
              ),
              jump: true,
              step: FlutterSliderStep(isPercentRange: false),
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(64),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, ThemeColors.textDark, ThemeColors.backgroundSecondary],
                    stops: [0.0, 0.3, 1.0],
                  ),
                ),
                activeTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(64),
                  color: theme.colorScheme.secondary,
                ),
                activeTrackBarHeight: trackBarHeight,
                inactiveTrackBarHeight: trackBarHeight,
              ),
              tooltip: FlutterSliderTooltip(disabled: true),
              hatchMark: FlutterSliderHatchMark(displayLines: false),
            ),
            // Vertical hatch marks
            for (int index = 1; index < maxIndex; index++)
              if (index != selectedIndex)
                Positioned(
                  left: hatchMarkPosition(index),
                  top: trackBarTop,
                  child: Container(
                    width: 0.5,
                    height: trackBarHeight,
                    color: ThemeColors.textDisabled.withValues(alpha: index < selectedIndex ? 1 : 0.3),
                  ),
                ),
            // Hatch mark labels
            for (int index = 0; index <= maxIndex; index++)
              Positioned(
                bottom: 0,
                left: hatchMarkPosition(index),
                child: FractionalTranslation(
                  translation: Offset(labelFractionalTranslationOffset(index), 0),
                  child: GestureDetector(
                    onTap: () => update(values[index]),
                    child: SliderHatchMarkLabel(getLabel(values[index]), selected: index == selectedIndex),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class SliderHatchMarkLabel extends StatelessWidget {
  final String label;
  final bool selected;

  const SliderHatchMarkLabel(this.label, {super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.apply(color: selected ? ThemeColors.textDark : ThemeColors.textDisabled),
    );
  }
}
