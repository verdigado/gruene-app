import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

class ProgressWithLabel extends StatelessWidget {
  final double value;
  final String label;

  final bool moveLabelWithProgress;

  const ProgressWithLabel({super.key, required this.value, required this.label, this.moveLabelWithProgress = false})
    : assert(value >= 0 && value <= 1, 'value must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    // Clamp value for safe alignment interpolation
    final clampedValue = value.clamp(0.0, 1.0);

    // Position label horizontally based on progress, keep vertically centered
    final alignment = Alignment(
      // Map 0.0-1.0 to -0.8 to 0.8 (leaves margin at edges)
      -0.8 + (moveLabelWithProgress ? (clampedValue * 1.6) : 0),
      0, // Vertically centered on the progress bar
    );

    return Stack(
      children: [
        LinearPercentIndicator(
          percent: value,
          lineHeight: 20,
          progressColor: ThemeColors.primary,
          backgroundColor: ThemeColors.grey200,
          barRadius: Radius.circular(10),
          padding: EdgeInsets.zero,
        ),
        Align(
          alignment: alignment,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _buildLabel(context)),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Stack(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = ThemeColors.primary,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.apply(color: ThemeColors.grey200),
        ),
      ],
    );
  }
}
