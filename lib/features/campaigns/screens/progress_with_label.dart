import 'package:flutter/material.dart';

class ProgressWithLabel extends StatelessWidget {
  final double value;
  final String label;

  const ProgressWithLabel({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: value),
        Align(
          alignment:
              AlignmentGeometry.lerp(const Alignment(-1.04, -1), const Alignment(1.04, -1), value) as AlignmentGeometry,
          child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
        ),
      ],
    );
  }
}
