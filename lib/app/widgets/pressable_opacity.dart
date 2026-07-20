import 'package:flutter/material.dart';

class PressableOpacity extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const PressableOpacity({super.key, required this.onTap, required this.child});

  @override
  State<PressableOpacity> createState() => PressableOpacityState();
}

class PressableOpacityState extends State<PressableOpacity> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.5 : 1,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
