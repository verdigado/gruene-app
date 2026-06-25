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
    this.width = 40,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: ShapeDecoration(
        color: selected ? iconColor : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: selected ? backgroundColor : iconColor, width: 1),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.all(7),
        icon: Icon(icon, color: selected ? backgroundColor : iconColor),
        onPressed: onPressed,
        style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
