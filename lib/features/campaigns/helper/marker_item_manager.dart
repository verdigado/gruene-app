import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';

class MarkerItemManager {
  List<MarkerItemModel> loadedMarkers = [];
  final List<MarkerItemModel> virtualMarkers = [];

  void addMarkers(List<MarkerItemModel> poiList) {
    // get virtual marker items and add them to cache list
    var newVirtualMarkers = poiList.where((p) => p.isVirtual).toList();
    virtualMarkers.retainWhere((oldMarker) => !newVirtualMarkers.any((newMarker) => newMarker.id == oldMarker.id));
    virtualMarkers.addAll(newVirtualMarkers);

    // get marker items which are not in cache
    var newStoredMarkers = poiList
        .where((p) => !p.isVirtual)
        .where((p) => !virtualMarkers.any((virtualMarker) => virtualMarker.id == p.id))
        .toList();

    // remove previously loaded markers to update them
    loadedMarkers.retainWhere((oldMarker) => !newStoredMarkers.any((newMarker) => newMarker.id == oldMarker.id));

    // remove loaded markers which are also in cache
    loadedMarkers.removeWhere((oldMarker) => virtualMarkers.any((cachedMarker) => cachedMarker.id == oldMarker.id));

    loadedMarkers.addAll(newStoredMarkers);
  }

  List<MarkerItemModel> getMarkers() {
    return loadedMarkers + virtualMarkers;
  }

  void removeMarker(int markerItemId) {
    loadedMarkers.retainWhere((item) => item.id == null || item.id != markerItemId);
  }

  void resetAllMarkers() {
    loadedMarkers.clear();
    virtualMarkers.clear();
  }
}
