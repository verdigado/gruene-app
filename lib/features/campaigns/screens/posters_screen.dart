import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_poster_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_list_item_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_update_model.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/screens/my_poster_list_screen.dart';
import 'package:gruene_app/features/campaigns/screens/poster_add_screen.dart';
import 'package:gruene_app/features/campaigns/screens/poster_detail.dart';
import 'package:gruene_app/features/campaigns/screens/poster_edit.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/features/campaigns/widgets/filter_chip_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/map_with_location.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class PostersScreen extends StatefulWidget {
  const PostersScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PostersScreenState();
}

class _PostersScreenState extends MapConsumer<PostersScreen, PosterCreateModel, PosterUpdateModel> {
  static const _poiType = PoiServiceType.poster;
  final _grueneApiService = GetIt.I<GrueneApiPosterService>();

  late List<FilterChipModel> postersFilter;

  _PostersScreenState() : super(_poiType);

  @override
  GrueneApiPosterService get campaignService => _grueneApiService;

  @override
  void initState() {
    postersFilter = [
      FilterChipModel(
        text: t.campaigns.filters.routes,
        isEnabled: false,
      ),
      FilterChipModel(
        text: t.campaigns.filters.focusAreas,
        isEnabled: true,
        stateChanged: onFocusAreaStateChanged,
      ),
      FilterChipModel(
        text: t.campaigns.filters.polling_stations,
        isEnabled: false,
      ),
      FilterChipModel(
        text: t.campaigns.filters.experience_areas,
        isEnabled: false,
      ),
    ];

    super.initState();
  }

  @override
  Widget build(localContext) {
    var mapContainer = MapWithLocation(
      onMapCreated: onMapCreated,
      addPOIClicked: _addPOIClicked,
      loadVisibleItems: loadVisibleItems,
      loadCachedItems: loadCachedItems,
      getMarkerImages: _getMarkerImages,
      onFeatureClick: _onFeatureClick,
      onNoFeatureClick: _onNoFeatureClick,
      addMapLayersForContext: addMapLayersForContext,
      loadDataLayers: loadDataLayers,
      showMapInfoAfterCameraMove: showMapInfoAfterCameraMove,
    );

    final theme = Theme.of(localContext);

    return Column(
      children: [
        FilterChipCampaign(postersFilter, <String, List<String>>{}),
        Expanded(
          child: Stack(
            children: [
              mapContainer,
              Positioned(
                bottom: 20,
                left: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.secondary,
                    foregroundColor: ThemeColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: ThemeColors.background,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: showMyPosters,
                  child: Text(
                    t.campaigns.poster.my_posters_action,
                    style: theme.textTheme.bodyMedium?.apply(
                      color: ThemeColors.background,
                      letterSpacingDelta: 1,
                      fontWeightDelta: 5,
                    ),
                  ),
                ),
              ),
              ...getSearchWidgets(context),
            ],
          ),
        ),
      ],
    );
  }

  Future<File?> _acquireAdditionalDataBeforeShowingAddScreen(BuildContext context) async {
    return await MediaHelper.acquirePhoto(context);
  }

  PosterAddScreen _getAddScreen(LatLng location, AddressModel? address, File? photo) {
    return PosterAddScreen(
      location: location,
      address: address!,
      photo: photo,
    );
  }

  void _addPOIClicked(LatLng location) async {
    super.addPOIClicked<File, PosterAddScreen, PosterCreateModel>(
      location,
      _acquireAdditionalDataBeforeShowingAddScreen,
      _getAddScreen,
      saveNewAndGetMarkerItem,
    );
  }

  Map<String, String> _getMarkerImages() {
    return {
      'poster_ok': CampaignConstants.posterOkAssetName,
      'poster_damaged': CampaignConstants.posterDamagedAssetName,
      'poster_missing': CampaignConstants.posterDamagedAssetName,
      'poster_removed': CampaignConstants.posterRemovedAssetName,
    };
  }

  Future<PosterDetailModel> _getPoi(String poiId) async {
    final poster = await campaignService.getPoiAsPosterDetail(poiId);
    return poster;
  }

  Future<PosterDetailModel> _getCachedPoi(String poiId) async {
    final poster = await campaignActionCache.getPoiAsPosterDetail(poiId);
    return poster;
  }

  Future<PosterDetailModel> _getPoiFromCacheOrApi(String poiId) async {
    if (await campaignActionCache.isCached(poiId)) {
      return _getCachedPoi(poiId);
    } else {
      return _getPoi(poiId);
    }
  }

  Widget _getEditPosterWidget(PosterDetailModel poster) {
    return PosterEdit(poster: poster, onSave: savePoi, onDelete: deletePoi);
  }

  void _onFeatureClick(dynamic rawFeature) async {
    final feature = rawFeature as Map<String, dynamic>;
    final isCached = MapHelper.extractIsCachedFromFeature(feature);

    getPoiDetailWidget(PosterDetailModel poster) {
      return PosterDetail(
        poi: poster,
      );
    }

    var getPoiFromCacheOrApi = isCached ? _getCachedPoi : _getPoi;

    super.onFeatureClick<PosterDetailModel>(
      rawFeature,
      getPoiFromCacheOrApi,
      getPoiDetailWidget,
      _getEditPosterWidget,
      desiredSize: Size(150, 150),
    );
  }

  void _onNoFeatureClick(Point<double> point) {
    showFocusAreaInfoAtPoint(point);
  }

  void showMyPosters() async {
    final theme = Theme.of(context);

    final myPosters = await getAllMyPosters();
    myPosters.sort((b, a) => a.createdAt.compareTo(b.createdAt));

    var navState = getNavState();
    // ignore: unused_local_variable
    final result = await navState.push(
      AppRoute<void>(
        builder: (context) {
          return ContentPage(
            contentBackgroundColor: theme.colorScheme.surfaceDim,
            title: getCurrentRoute().name ?? '',
            alignment: Alignment.topCenter,
            child: MyPosterListScreen(
              myPosters: myPosters,
              getPoi: _getPoiFromCacheOrApi,
              getPoiEdit: _getEditPosterWidget,
              reloadPosterListItem: _getPosterListItem,
            ),
          );
        },
      ),
    );
  }

  Future<List<PosterListItemModel>> getAllMyPosters() async {
    var myPosters = await campaignService.getMyPosters();
    await campaignActionCache.replaceAndFillUpMyPosterList(myPosters);
    return myPosters;
  }

  Future<PosterListItemModel> _getPosterListItem(String id) async {
    return await campaignActionCache.isCached(id)
        ? campaignActionCache.getPoiAsPosterListItem(id)
        : campaignService.getPoiAsPosterListItem(id);
  }
}
