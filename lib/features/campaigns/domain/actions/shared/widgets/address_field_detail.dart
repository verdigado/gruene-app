import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gruene_app/app/theme/theme.dart';

/// Street and house number, right-aligned on one line.
///
/// The house number is always shown in full. The street takes the remaining width and ends with an ellipsis
/// if it does not fit. It never widens its parent: a popover sized to its content gets its width from the
/// other content, and the street uses what is there.
class AddressFieldDetail extends StatelessWidget {
  const AddressFieldDetail({super.key, required this.street, required this.houseNumber});

  final String street;
  final String houseNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressTextStyle = theme.textTheme.labelSmall?.apply(color: ThemeColors.secondary, fontWeightDelta: 3);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _IgnoreIntrinsicWidth(
              child: Text(street, style: addressTextStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          SizedBox(width: 3),
          Text(houseNumber, style: addressTextStyle),
        ],
      ),
    );
  }
}

/// Reports no intrinsic width, so a parent sizing itself to its content (e.g. [IntrinsicWidth]) does not
/// grow for [child]. In layout, [child] still takes the width it is given.
class _IgnoreIntrinsicWidth extends SingleChildRenderObjectWidget {
  const _IgnoreIntrinsicWidth({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderIgnoreIntrinsicWidth();
}

class _RenderIgnoreIntrinsicWidth extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;
}
