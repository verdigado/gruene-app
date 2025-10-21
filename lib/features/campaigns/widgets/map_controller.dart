import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/models/bounding_box.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:gruene_app/features/campaigns/widgets/map_container.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/transform.dart';

abstract class MapController {
  void setMarkerSource(List<MarkerItemModel> poiList);
  void addMarkerItem(MarkerItemModel markerItem);
  void removeMarkerItem(int markerItemId);

  Future<m.Point<num>?> getScreenPointFromLatLng(LatLng coord);

  Future<List<dynamic>> getFeaturesInScreen(m.Point<double> point, List<String> layers);

  Future<dynamic> getClosestFeaturesInScreen(m.Point<double> point, List<String> layers);

  void showMapPopover(LatLng coord, Widget widget, OnEditItemClickedCallback? onEditItemClicked, Size desiredSize);

  void setLayerSourceWithFeatureCollection(String sourceId, FeatureCollection layerData);

  void removeLayerSource(String layerSourceId);

  Future<BoundingBox> getCurrentBoundingBox();
  double getCurrentZoomLevel();

  double get minimumMarkerZoomLevel;

  void toggleInfoForMissingMapFeatures(bool enable);

  void navigateMapTo(LatLng location);

  Future<void> setFocusToMarkerItem(Map<String, dynamic> feature);
  Future<void> unsetFocusToMarkerItem();
}
