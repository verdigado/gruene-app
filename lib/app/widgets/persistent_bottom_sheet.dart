import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/bottom_sheet_handle.dart';

const double defaultBottomSheetSize = 0.2;

class PersistentBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;

  const PersistentBottomSheet({
    super.key,
    required this.child,
    this.initialChildSize = defaultBottomSheetSize,
    this.minChildSize = defaultBottomSheetSize,
    this.maxChildSize = 1,
    this.snapSizes = const [],
  });

  @override
  State<PersistentBottomSheet> createState() => _PersistentBottomSheetState();
}

class _PersistentBottomSheetState extends State<PersistentBottomSheet> {
  final _controller = DraggableScrollableController();
  final _sheet = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  DraggableScrollableSheet get sheet => (_sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: 0,
      child: DraggableScrollableSheet(
        key: _sheet,
        initialChildSize: widget.initialChildSize,
        minChildSize: widget.minChildSize,
        maxChildSize: widget.maxChildSize,
        snapSizes: widget.snapSizes,
        controller: _controller,
        snap: true,
        expand: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    BottomSheetHandle(),
                    Container(padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16), child: widget.child),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
