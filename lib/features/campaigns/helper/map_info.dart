// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller.dart';

class MapInfo {
  MapController mapController;
  double minZoom;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? lastInfoSnackbar;
  BuildContext context;
  LoadCachedLayerCallback loadCachedLayer;

  MapInfo({
    required this.mapController,
    required this.minZoom,
    required this.lastInfoSnackbar,
    required this.context,
    required this.loadCachedLayer,
  });
}
