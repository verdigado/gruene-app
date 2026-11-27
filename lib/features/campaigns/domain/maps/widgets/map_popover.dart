import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// Popover above a point on the map, with a close button and an edit link above [child].
///
/// With [desiredSize] it has a fixed size, otherwise it takes the size of [child], at most the screen width.
/// Must be placed in a [Stack]: the tip of its arrow is 5 px above [anchor], centered on it.
class MapPopover extends StatelessWidget {
  final Offset anchor;
  final Size? desiredSize;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final Widget child;

  static const _arrowHeight = 10.0;

  const MapPopover({
    super.key,
    required this.anchor,
    required this.onClose,
    required this.onEdit,
    required this.child,
    this.desiredSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final popupHeight = desiredSize == null ? null : desiredSize!.height - 15;

    Widget popover = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: desiredSize?.width,
          height: popupHeight == null ? null : popupHeight + 5,
          decoration: BoxDecoration(color: ThemeColors.background, borderRadius: BorderRadius.circular(5)),
          // no bottom padding with a fixed size: the heights below already fill it
          padding: EdgeInsets.only(top: 3, left: 6, right: 6, bottom: desiredSize == null ? 3 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(onTap: onClose, child: Icon(Icons.close_outlined, size: 14)),
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1.5, color: ThemeColors.textDark)),
                        ),
                        child: Text(
                          t.common.actions.edit,
                          style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDark, fontWeightDelta: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: SizedBox(
                  width: desiredSize?.width,
                  height: popupHeight == null ? null : popupHeight - 25,
                  child: child,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: ClipPath(
            clipper: _ArrowClipper(),
            child: Container(color: ThemeColors.background, width: 15, height: _arrowHeight),
          ),
        ),
      ],
    );

    if (desiredSize == null) {
      // sized to its content: as wide as the content needs on one line, at most the screen width
      popover = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 32),
        child: IntrinsicWidth(child: popover),
      );
    }

    return Positioned(
      top: anchor.dy - 5,
      left: anchor.dx,
      // moves the popover up by its height and left by half its width, so this works for any size
      child: FractionalTranslation(translation: const Offset(-0.5, -1), child: popover),
    );
  }
}

class _ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon([Offset(0, 0), Offset(size.width / 2, size.height), Offset(size.width, 0)], true);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
