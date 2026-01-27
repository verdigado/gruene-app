import 'package:flutter/material.dart' hide Route;
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class MapContainerController extends ChangeNotifier {
  Route? _route;
  Area? _area;

  Area? get area => _area;
  Route? get route => _route;

  void showRoute(Route route) {
    reset();
    _route = route;
    notifyListeners();
  }

  void showArea(Area area) {
    reset();
    _area = area;
    notifyListeners();
  }

  void reset() {
    _area = null;
    _route = null;
  }
}
