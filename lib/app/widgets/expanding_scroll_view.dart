import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';

// This widget allows to push content to the bottom (e.g. using Spacer()) while enabling scrolling behavior if the content is overflowing the vertically available space
class ExpandingScrollView extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;
  final double spacing;

  const ExpandingScrollView({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = defaultScreenPadding,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: constraints.copyWith(minHeight: constraints.maxHeight, maxHeight: double.infinity),
          child: IntrinsicHeight(
            child: Padding(
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, spacing: spacing, children: children),
            ),
          ),
        ),
      ),
    );
  }
}
