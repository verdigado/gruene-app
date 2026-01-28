import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/models/bounding_box.dart';
import 'package:gruene_app/features/campaigns/widgets/map_container.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/turf.dart' as turf;

abstract class MapController {
  void setPoiMarkerSource(List<turf.Feature> poiList);
  void addPoiMarkerItem(turf.Feature markerItem);

  Future<m.Point<num>?> getScreenPointFromLatLng(LatLng coord);

  Future<List<dynamic>> getFeaturesInScreen(m.Point<double> point, String displayLayer, String sourceLayer);

  Future<dynamic> getClosestFeaturesInScreen(m.Point<double> point, String displayLayer, String sourceLayer);

  void showMapPopover(LatLng coord, Widget widget, OnEditItemClickedCallback? onEditItemClicked, Size desiredSize);

  Future<void> setLayerSourceWithFeatureList(String sourceId, List<turf.Feature> layerData);

  Future<void> removeLayerSource(String layerSourceId);

  Future<BoundingBox> getCurrentBoundingBox();
  double getCurrentZoomLevel();

  double get minimumMarkerZoomLevel;

  void toggleInfoForMissingMapFeatures(bool enable);

  void navigateMapTo(LatLng location);

  Future<void> setFocusToMarkerItem(Map<String, dynamic> feature);
  Future<void> unsetFocusToMarkerItem();
}
