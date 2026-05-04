import 'package:flutter/material.dart';

class HorizontalDivider extends StatelessWidget {
  final Color? color;

  const HorizontalDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: color ?? theme.primaryColor, shape: BoxShape.circle),
    );
  }
}
