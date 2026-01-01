part of '../mixins.dart';

mixin MapContainerExperienceAreaMixin {
  void removeLayerSource(String layerSourceId);

  Future<void> onExperienceAreaClick(
    dynamic feature,
    BuildContext Function() getContext,
    OnShowBottomDetailSheet showBottomDetailSheet,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    var experienceAreaFeature = turf.Feature.fromJson(feature as Map<String, dynamic>);
    var experienceAreaDetail = await _getExperienceAreaDetailWidget(experienceAreaFeature, getContext());
    // set data for '_selected layer'
    // var collection = turf.FeatureCollection(features: [experienceAreaFeature]);
    // await _controller!.setGeoJsonSource(CampaignConstants.experienceAreaSelectedSourceName, collection.toJson());
    await _setFocusToExperienceArea(feature, setFocusMode, getMapController);

    await showBottomDetailSheet<bool>(experienceAreaDetail);
    await _unsetFocusToExperienceArea(feature, setFocusMode, getMapController);
  }

  Future<void> _setFocusToExperienceArea(
    Map<String, dynamic> feature,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    setFocusMode(true);

    // align map to show feature in center area
    // TODO determine boundary of area and move map
    // final coord = MapHelper.extractLatLngFromFeature(feature);
    // await moveMapIfItemIsOnBorder(coord, Size(150, 150));

    // set opacity of marker layer
    await getMapController()!.setLayerProperties(
      CampaignConstants.experienceAreaLayerId,
      FillLayerProperties(visibility: 'none'),
    );
    await getMapController()!.setLayerProperties(
      CampaignConstants.experienceAreaOutlineLayerId,
      LineLayerProperties(visibility: 'none'),
    );

    // set data for '_selected layer'
    var featureObject = turf.Feature.fromJson(feature);
    var collection = turf.FeatureCollection(features: [featureObject]);
    await getMapController()!.setGeoJsonSource(CampaignConstants.experienceAreaSelectedSourceName, collection.toJson());
  }

  Future<void> _unsetFocusToExperienceArea(
    Map<String, dynamic> feature,
    void Function(bool) setFocusMode,
    MapLibreMapController? Function() getMapController,
  ) async {
    setFocusMode(false);

    await getMapController()!.setLayerProperties(
      CampaignConstants.experienceAreaLayerId,
      FillLayerProperties(visibility: 'visible'),
    );
    await getMapController()!.setLayerProperties(
      CampaignConstants.experienceAreaOutlineLayerId,
      LineLayerProperties(visibility: 'visible'),
    );
    removeLayerSource(CampaignConstants.experienceAreaSelectedSourceName);
  }

  Future<Widget> _getExperienceAreaDetailWidget(turf.Feature experienceAreaFeature, BuildContext context) async {
    var theme = Theme.of(context);
    var experienceAreaService = GetIt.I<GrueneApiExperienceAreaService>();
    var experienceArea = await experienceAreaService.getExperienceArea(experienceAreaFeature.id.toString());

    onClose() => Navigator.maybePop(context);

    return SizedBox(
      height: 150,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: CloseEditWidget(onClose: () => onClose()),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.radar_outlined),
                      SizedBox(width: 7),
                      Text(
                        t.campaigns.experience_areas.label,
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: ThemeColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        experienceArea.description.safe(),
                        style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.experience_areas.supplied_by}: ${t.campaigns.experience_areas.general_supplier}',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${t.campaigns.general.createdAt}: ${experienceArea.createdAt.getAsLocalDateString()}',
                        style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
