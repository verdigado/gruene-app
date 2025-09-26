import 'package:flutter/material.dart';

class BottomSheetState {
  final Widget? content;

  const BottomSheetState({this.content});

  bool get isVisible => content != null;
}
