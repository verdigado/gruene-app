import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/controllers/map_container_controller.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/map_with_location.dart';

/// Map of the Stand tab.
///
/// Stands are not loaded yet: their pins (#1269) and adding a stand (#1268)
/// build on the stand API client (#1266).
class StandScreen extends StatefulWidget {
  const StandScreen({super.key});

  @override
  State<StandScreen> createState() => _StandScreenState();
}

class _StandScreenState extends State<StandScreen> {
  final MapContainerController _mapContainerController = MapContainerController();

  @override
  void dispose() {
    _mapContainerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapWithLocation(
      mapContainerController: _mapContainerController,
      onMapCreated: null,
      addPOIClicked: null,
      loadVisiblePois: null,
      getMarkerImages: () => {},
      getBasicPoiFromFeature: _getBasicPoiFromFeature,
      onFeatureClick: null,
      onNoFeatureClick: null,
      showBottomDetailSheet: _showBottomDetailSheet,
      showMapInfoAfterCameraMove: null,
      addMapLayersForContext: (_) async {},
    );
  }

  Future<BasicPoi> _getBasicPoiFromFeature(Map<String, dynamic> feature) =>
      throw UnsupportedError('The stand map shows no pins yet');

  Future<U?> _showBottomDetailSheet<U>(Widget detailWidget) async => null;
}
