import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  final void Function() onPressed;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool selected;

  const RoundedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: selected ? backgroundColor : iconColor, width: 1),
        shape: BoxShape.circle,
      ),
      child: Ink(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          color: selected ? iconColor : backgroundColor,
          shape: CircleBorder(),
        ),
        child: IconButton(
          icon: Icon(
            Icons.filter_list_rounded,
            color: selected ? backgroundColor : iconColor,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
