import 'package:gruene_app/app/services/converters.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/turf.dart' as turf;

typedef GetMapLibreMapController = MapLibreMapController? Function();

class MapFeatureManager {
  final _allFeatureLayers = <String, MapFeatureLayer>{};
  final GetMapLibreMapController getMapLibreMapController;

  MapFeatureManager(this.getMapLibreMapController);

  void addMarkers(String sourceId, List<turf.Feature> poiList) {
    var currentLayer = _getCurrentSourceLayer(sourceId);

    var loadedMarkers = currentLayer.loadedMarkers;
    var virtualMarkers = currentLayer.virtualMarkers;
    // get virtual marker items and add them to cache list
    var newVirtualMarkers = poiList.where((p) => p.isVirtual()).toList();
    virtualMarkers.retainWhere((oldMarker) => !newVirtualMarkers.any((newMarker) => newMarker.id == oldMarker.id));
    virtualMarkers.addAll(newVirtualMarkers);

    // get marker items which are not in cache
    var newStoredMarkers = poiList
        .where((p) => !p.isVirtual())
        .where((p) => !virtualMarkers.any((virtualMarker) => virtualMarker.id == p.id))
        .toList();

    // remove previously loaded markers to update them
    loadedMarkers.retainWhere((oldMarker) => !newStoredMarkers.any((newMarker) => newMarker.id == oldMarker.id));

    // remove loaded markers which are also in cache
    loadedMarkers.removeWhere((oldMarker) => virtualMarkers.any((cachedMarker) => cachedMarker.id == oldMarker.id));

    loadedMarkers.addAll(newStoredMarkers);
  }

  MapFeatureLayer _getCurrentSourceLayer(String sourceId) {
    if (!_allFeatureLayers.containsKey(sourceId)) _allFeatureLayers[sourceId] = MapFeatureLayer();
    var currentLayer = _allFeatureLayers[sourceId]!;
    return currentLayer;
  }

  List<turf.Feature> getMarkers(String sourceId) {
    var currentLayer = _getCurrentSourceLayer(sourceId);
    return currentLayer.loadedMarkers + currentLayer.virtualMarkers;
  }

  void removeMarker(String sourceId, int markerItemId) {
    var currentLayer = _getCurrentSourceLayer(sourceId);
    currentLayer.loadedMarkers.retainWhere((item) => item.id == null || item.id != markerItemId);
  }

  void resetAllMarkers() {
    _allFeatureLayers.clear();
  }
}

class MapFeatureLayer {
  final List<turf.Feature> loadedMarkers = [];
  final List<turf.Feature> virtualMarkers = [];
}
