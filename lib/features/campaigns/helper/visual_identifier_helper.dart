import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_visual_identifier_service.dart';

class VisualIdentifierHelper {
  static Map<int, String>? _visualIdentifierMap;

  void ensureInitialized() async {
    if (_visualIdentifierMap == null) {
      var visualIdentifierService = GetIt.I.get<GrueneApiVisualIdentifierService>();
      var visualIdentifiersData = (await visualIdentifierService.getVisualIdentifiers());
      _visualIdentifierMap = {for (var e in visualIdentifiersData) e.id: e.color};
    }
  }

  void reset() {
    _visualIdentifierMap = null;
  }

  String getVisualIdentifierById(int? id, {required String fallbackColor}) {
    if (_visualIdentifierMap == null) {
      throw Exception('Visual identifiers not initialized. Call ensureInitialized() first.');
    }
    if (id == null) {
      return getVisualIdentifierById(0, fallbackColor: fallbackColor);
    }

    var currentVisualIdentifier = (_visualIdentifierMap?[id] ?? _visualIdentifierMap?[0]);
    return currentVisualIdentifier ?? fallbackColor;
  }
}
