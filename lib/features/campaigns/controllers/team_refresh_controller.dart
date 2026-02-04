import 'package:flutter/material.dart';

class TeamRefreshController extends ChangeNotifier {
  void reload() {
    notifyListeners();
  }
}
