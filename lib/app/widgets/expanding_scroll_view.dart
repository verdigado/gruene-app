import 'package:flutter/material.dart';

// This widget allows to push content to the bottom (e.g. using Spacer()) while enabling scrolling behavior if the content is overflowing the vertically available space
class ExpandingScrollView extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  const ExpandingScrollView({super.key, required this.children, this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: constraints.copyWith(minHeight: constraints.maxHeight, maxHeight: double.infinity),
          child: IntrinsicHeight(
            child: Column(crossAxisAlignment: crossAxisAlignment, children: children),
          ),
        ),
      ),
    );
  }
}
