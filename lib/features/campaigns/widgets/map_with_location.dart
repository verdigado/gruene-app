import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/location/determine_position.dart';
import 'package:gruene_app/features/campaigns/widgets/map_container.dart';

class MapWithLocation extends StatelessWidget {
  final OnMapCreatedCallback? onMapCreated;
  final AddPOIClickedCallback? addPOIClicked;
  final LoadVisibleItemsCallBack? loadVisibleItems;
  final LoadCachedItemsCallback? loadCachedItems;
  final LoadDataLayersCallBack? loadDataLayers;
  final GetMarkerImagesCallback? getMarkerImages;
  final OnFeatureClickCallback? onFeatureClick;
  final OnNoFeatureClickCallback? onNoFeatureClick;
  final AddMapLayersForContextCallback? addMapLayersForContext;
  final ShowMapInfoAfterCameraMoveCallback? showMapInfoAfterCameraMove;

  const MapWithLocation({
    super.key,
    required this.onMapCreated,
    required this.addPOIClicked,
    required this.loadVisibleItems,
    required this.loadCachedItems,
    required this.getMarkerImages,
    required this.onFeatureClick,
    required this.onNoFeatureClick,
    required this.showMapInfoAfterCameraMove,
    this.loadDataLayers,
    this.addMapLayersForContext,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: determinePosition(context, requestIfNotGranted: false, preferLastKnownPosition: true)
          .timeout(const Duration(milliseconds: 400), onTimeout: () => RequestedPosition.unknown()),
      builder: (context, AsyncSnapshot<RequestedPosition> snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center();
        }

        final position = snapshot.data;

        return MapContainer(
          onMapCreated: onMapCreated,
          addPOIClicked: addPOIClicked,
          loadVisibleItems: loadVisibleItems,
          loadCachedItems: loadCachedItems,
          getMarkerImages: getMarkerImages,
          onFeatureClick: onFeatureClick,
          onNoFeatureClick: onNoFeatureClick,
          addMapLayersForContext: addMapLayersForContext,
          loadDataLayers: loadDataLayers,
          showMapInfoAfterCameraMove: showMapInfoAfterCameraMove,
          locationAvailable: position?.isAvailable() ?? false,
          userLocation: position?.toLatLng(),
        );
      },
    );
  }
}
