import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcon extends StatelessWidget {
  final String path;
  final Color color;
  final double width;
  final double height;

  const CustomIcon({super.key, required this.path, required this.color, this.width = 24, this.height = 24});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(path, width: width, height: height, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }
}
