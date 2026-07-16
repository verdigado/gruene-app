import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/logger.dart';

class ProgressWithLabel extends StatelessWidget {
  final double value;
  final String label;

  const ProgressWithLabel({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LinearProgressIndicator(value: value, minHeight: 20),
        Align(
          alignment:
              AlignmentGeometry.lerp(const Alignment(-1, -1), const Alignment(1, -1), value) as AlignmentGeometry,
          child: Stack(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.5
                    ..color = ThemeColors.secondary,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.apply(color: ThemeColors.grey200),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
