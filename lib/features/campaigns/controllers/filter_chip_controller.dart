import 'package:flutter/material.dart';

class FilterChipController extends ChangeNotifier {
  String? _filterChipLabel;

  String? get value => _filterChipLabel;

  void enableFilterChip(String value) {
    _filterChipLabel = value;
    notifyListeners();
  }
}
