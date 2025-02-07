import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  final void Function() onPressed;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool selected;
  final double width;
  final double height;

  const RoundedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.selected = false,
    this.width = 48,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: selected ? backgroundColor : iconColor, width: 1),
        ),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: selected ? iconColor : backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: IconButton(
          icon: Icon(icon, color: selected ? backgroundColor : iconColor),
          onPressed: onPressed,
          style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}
