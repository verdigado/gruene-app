import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 6,
        decoration: BoxDecoration(color: ThemeColors.textLight, borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
    );
  }
}
