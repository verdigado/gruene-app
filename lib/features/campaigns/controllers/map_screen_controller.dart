import 'package:flutter/material.dart';

class MapScreenController extends ChangeNotifier {
  String? _routeId;
  String? _areaId;

  String? get areaId => _areaId;
  String? get routeId => _routeId;

  void showRoute(String routeId) {
    reset();
    _routeId = routeId;
    notifyListeners();
  }

  void showArea(String areaId) {
    reset();
    _areaId = areaId;
    notifyListeners();
  }

  void reset() {
    _areaId = null;
    _routeId = null;
  }
}
