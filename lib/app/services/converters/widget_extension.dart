part of '../converters.dart';

extension WidgetExtension on Widget {
  Widget disable({int alpha = 170}) {
    return Stack(
      children: [
        this,
        Positioned.fill(child: Container(color: ThemeColors.disabledShadow.withAlpha(alpha))),
      ],
    );
  }

  Widget withOpacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }
}
