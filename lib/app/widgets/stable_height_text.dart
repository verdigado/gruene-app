import 'package:flutter/material.dart';

class StableHeightText extends StatelessWidget {
  final String text;
  final String longestText;
  final TextStyle style;

  const StableHeightText({super.key, required this.text, required this.longestText, required this.style});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final textPainter = TextPainter(
      text: TextSpan(text: longestText, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 5,
    )..layout(maxWidth: maxWidth);
    final maxHeight = textPainter.size.height;

    return SizedBox(
      height: maxHeight,
      child: Text(text, style: style),
    );
  }
}
