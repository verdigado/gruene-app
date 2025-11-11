import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/campaign_action_database.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_action_area_service.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/services/gruene_api_door_service.dart';
import 'package:gruene_app/app/services/gruene_api_flyer_service.dart';
import 'package:gruene_app/app/services/gruene_api_poster_service.dart';
import 'package:gruene_app/app/services/gruene_api_route_service.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:gruene_app/features/campaigns/models/action_area/action_area_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/action_area/action_area_update_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_create_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_update_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_create_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_update_model.dart';
import 'package:gruene_app/features/campaigns/models/poi_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_list_item_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_update_model.dart';
import 'package:gruene_app/features/campaigns/models/route/route_update_model.dart';
import 'package:gruene_app/features/campaigns/widgets/map_controller_simplified.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class CampaignActionCache extends ChangeNotifier {
  static CampaignActionCache? _instance;
  static bool _isflushing = false;
  var campaignActionDatabase = CampaignActionDatabase.instance;

  MapControllerSimplified? _currentMapController;

  CampaignActionCache._();

  factory CampaignActionCache() => _instance ??= CampaignActionCache._();

  bool get isFlushing => _isflushing;

  Future<bool> isCached(String poiId, PoiCacheType poiType) async {
    return campaignActionDatabase.actionsWithPoiIdExists(poiId, _getActionsForCacheType(poiType));
  }

  Future<void> _appendActionToCache(CampaignAction action) async {
    await campaignActionDatabase.create(action);
    notifyListeners();
  }

  Future<void> _updateAction(CampaignAction action) async {
    await campaignActionDatabase.update(action);
  }

  Future<int> getCachedActionCount() {
    return campaignActionDatabase.getCount();
  }

  Future<PoiDetailModel> storeNewPoi(PoiCacheType poiType, dynamic poiCreate) async {
    switch (poiType) {
      case PoiCacheType.poster:
        return await _addCreateAction<PosterCreateModel>(
          poiType: poiType,
          poi: poiCreate as PosterCreateModel,
          getJson: (poi) => poi.toJson(),
          getMarker: (poi, tempId) => poi.transformToVirtualMarkerItem(tempId),
        );
      case PoiCacheType.door:
        return await _addCreateAction<DoorCreateModel>(
          poiType: poiType,
          poi: poiCreate as DoorCreateModel,
          getJson: (poi) => poi.toJson(),
          getMarker: (poi, tempId) => poi.transformToVirtualMarkerItem(tempId),
        );
      case PoiCacheType.flyer:
        return await _addCreateAction<FlyerCreateModel>(
          poiType: poiType,
          poi: poiCreate as FlyerCreateModel,
          getJson: (poi) => poi.toJson(),
          getMarker: (poi, tempId) => poi.transformToVirtualMarkerItem(tempId),
        );
      case PoiCacheType.route:
        throw UnimplementedError();
      case PoiCacheType.actionArea:
        throw UnimplementedError();
    }
  }

  Future<PoiDetailModel> _addCreateAction<T>({
    required PoiCacheType poiType,
    required T poi,
    required Map<String, dynamic> Function(T) getJson,
    required PoiDetailModel Function(T, int) getMarker,
  }) async {
    final action = CampaignAction(actionType: poiType.getCacheAddAction(), serialized: jsonEncode(getJson(poi)));
    await _appendActionToCache(action);
    return getMarker(poi, action.poiTempId);
  }

  Future<PoiDetailModel> deletePoi(PoiCacheType poiType, String poiId) async {
    final action = CampaignAction(poiId: int.parse(poiId), actionType: poiType.getCacheDeleteAction());

    var poiCacheList = await _findActionsByPoiId(poiId);
    var addActions = poiCacheList.where((p) => p.actionType == poiType.getCacheAddAction()).toList();
    if (addActions.isNotEmpty) {
      // create_action is in cache
      for (var action in poiCacheList) {
        campaignActionDatabase.delete(action.id!);
      }
      notifyListeners();
    } else {
      await _appendActionToCache(action);
    }
    return _getDeleteMarkerModel(poiType, action.poiId!);
  }

  Future<PoiDetailModel> updatePoi(PoiCacheType poiType, dynamic poi) async {
    var emptyMarkerItemModel = PoiDetailModel(id: null, status: null, location: LatLng(0, 0));
    switch (poiType) {
      case PoiCacheType.poster:
        return await _addUpdateAction<PosterUpdateModel>(
          poiType: poiType,
          poi: poi as PosterUpdateModel,
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => action.getAsPosterUpdate().mergeWith(poiUpdate),
          getMarker: (poi) => poi.transformToVirtualMarkerItem(),
        );
      case PoiCacheType.door:
        return await _addUpdateAction<DoorUpdateModel>(
          poiType: poiType,
          poi: poi as DoorUpdateModel,
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => poiUpdate,
          getMarker: (poi) => poi.transformToVirtualMarkerItem(),
        );
      case PoiCacheType.flyer:
        return await _addUpdateAction<FlyerUpdateModel>(
          poiType: poiType,
          poi: poi as FlyerUpdateModel,
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => poiUpdate,
          getMarker: (poi) => poi.transformToVirtualMarkerItem(),
        );
      case PoiCacheType.route:
        return await _addUpdateAction<RouteUpdateModel>(
          poiType: poiType,
          poi: poi as RouteUpdateModel,
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => poiUpdate,
          getMarker: (poi) => emptyMarkerItemModel,
        );
      case PoiCacheType.actionArea:
        return await _addUpdateAction<ActionAreaUpdateModel>(
          poiType: poiType,
          poi: poi as ActionAreaUpdateModel,
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => poiUpdate,
          getMarker: (poi) => emptyMarkerItemModel,
        );
    }
  }

  Future<PoiDetailModel> _addUpdateAction<T>({
    required PoiCacheType poiType,
    required T poi,
    required String Function(T) getId,
    required Map<String, dynamic> Function(T) getJson,
    required T Function(CampaignAction, T) mergeUpdates,
    required PoiDetailModel Function(T) getMarker,
  }) async {
    var actions = (await _findActionsByPoiId(getId(poi))).where((x) => x.actionType == poiType.getCacheEditAction());
    var action = actions.singleOrNull;
    if (action == null) {
      action = CampaignAction(
        poiId: int.parse(getId(poi)),
        actionType: poiType.getCacheEditAction(),
        serialized: jsonEncode(getJson(poi)),
      );
      await _appendActionToCache(action);
    } else {
      // update previous edit action
      var newPoiUpdate = mergeUpdates(action, poi);
      action.serialized = jsonEncode(getJson(newPoiUpdate));
      await _updateAction(action);
    }

    return getMarker(poi);
  }

  PoiDetailModel _getDeleteMarkerModel(PoiCacheType poiType, int id) {
    return PoiDetailModel.virtual(id: id, status: '${poiType.name}_deleted', location: LatLng(0, 0));
  }

  Future<List<PoiDetailModel>> getMarkerItems(PoiCacheType poiType) async {
    List<PoiDetailModel> markerItems = [];
    var poiActions = _getActionsForCacheType(poiType);
    final poiCacheList = await campaignActionDatabase.readAllByActionType(poiActions);
    poiCacheList.sort((a, b) => b.poiTempId.compareTo(a.poiTempId)); //reverse sort list by tempId (timestamped ID)
    for (var action in poiCacheList) {
      if (markerItems.any((m) => m.id == action.coalescedPoiId())) continue;
      switch (action.actionType) {
        case CampaignActionType.addPoster:
          var model = action.getAsPosterCreate();
          markerItems.add(model.transformToVirtualMarkerItem(action.poiTempId));
        case CampaignActionType.editPoster:
          var model = action.getAsPosterUpdate();
          markerItems.add(model.transformToVirtualMarkerItem());
        case CampaignActionType.deletePoster:
          var model = _getDeleteMarkerModel(PoiCacheType.poster, action.poiId!);
          markerItems.add(model);

        case CampaignActionType.addDoor:
          var model = action.getAsDoorCreate();
          markerItems.add(model.transformToVirtualMarkerItem(action.poiTempId));
        case CampaignActionType.editDoor:
          var model = action.getAsDoorUpdate();
          markerItems.add(model.transformToVirtualMarkerItem());
        case CampaignActionType.deleteDoor:
          var model = _getDeleteMarkerModel(PoiCacheType.door, action.poiId!);
          markerItems.add(model);

        case CampaignActionType.addFlyer:
          var model = action.getAsFlyerCreate();
          markerItems.add(model.transformToVirtualMarkerItem(action.poiTempId));
        case CampaignActionType.editFlyer:
          var model = action.getAsFlyerUpdate();
          markerItems.add(model.transformToVirtualMarkerItem());
        case CampaignActionType.deleteFlyer:
          var model = _getDeleteMarkerModel(PoiCacheType.flyer, action.poiId!);
          markerItems.add(model);

        case CampaignActionType.editRoute:
        case CampaignActionType.editActionArea:
        case CampaignActionType.unknown:
        case null:
          throw UnimplementedError();
      }
    }
    return markerItems;
  }

  List<int> _getActionsForCacheType(PoiCacheType poiType) {
    getValueSafe(CampaignActionType Function() getActionType) {
      try {
        return getActionType().index;
      } on UnimplementedError {
        return null;
      }
    }

    return [
      getValueSafe(() => poiType.getCacheAddAction()),
      getValueSafe(() => poiType.getCacheEditAction()),
      getValueSafe(() => poiType.getCacheDeleteAction()),
    ].where((x) => x != null).cast<int>().toList();
  }

  Future<PosterDetailModel> getPoiAsPosterDetail(String poiId) async {
    var detailModel = await _getPoiDetail<PosterDetailModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.addPoster,
      editActionFilter: CampaignActionType.editPoster,
      transformEditAction: (action) => action.getAsPosterUpdate().transformToPosterDetailModel(),
      transformAddAction: (action) => action.getAsPosterCreate().transformToPosterDetailModel(poiId),
    );
    return detailModel;
  }

  Future<DoorDetailModel> getPoiAsDoorDetail(String poiId) async {
    var detailModel = await _getPoiDetail<DoorDetailModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.addDoor,
      editActionFilter: CampaignActionType.editDoor,
      transformEditAction: (action) => action.getAsDoorUpdate().transformToDoorDetailModel(),
      transformAddAction: (action) => action.getAsDoorCreate().transformToDoorDetailModel(poiId),
    );
    return detailModel;
  }

  Future<FlyerDetailModel> getPoiAsFlyerDetail(String poiId) async {
    var detailModel = await _getPoiDetail<FlyerDetailModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.addFlyer,
      editActionFilter: CampaignActionType.editFlyer,
      transformEditAction: (action) => action.getAsFlyerUpdate().transformToFlyerDetailModel(),
      transformAddAction: (action) => action.getAsFlyerCreate().transformToFlyerDetailModel(poiId),
    );
    return detailModel;
  }

  Future<RouteUpdateModel> getPoiAsRouteDetail(String poiId) async {
    var detailModel = await _getPoiDetail<RouteUpdateModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.editRoute,
      editActionFilter: CampaignActionType.editRoute,
      transformEditAction: (action) => action.getAsRouteUpdate(),
      transformAddAction: (action) => action.getAsRouteUpdate(),
    );
    return detailModel;
  }

  Future<ActionAreaDetailModel> getPoiAsActionAreaDetail(String poiId) async {
    var detailModel = await _getPoiDetail<ActionAreaDetailModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.editActionArea,
      editActionFilter: CampaignActionType.editActionArea,
      transformEditAction: (action) => action.getAsActionAreaUpdate().transformToActionAreaDetailModel(),
      transformAddAction: (action) => action.getAsActionAreaUpdate().transformToActionAreaDetailModel(),
    );
    return detailModel;
  }

  Future<T> _getPoiDetail<T>({
    required String poiId,
    required CampaignActionType addActionFilter,
    required CampaignActionType editActionFilter,
    required T Function(CampaignAction) transformEditAction,
    required T Function(CampaignAction) transformAddAction,
  }) async {
    var cacheList = await _findActionsByPoiId(poiId);
    var editActions = cacheList.where((p) => p.actionType == editActionFilter).toList();
    if (editActions.isNotEmpty) {
      var editAction = editActions.single;
      return transformEditAction(editAction);
    } else {
      var addActions = cacheList.where((p) => p.actionType == addActionFilter).toList();
      var addAction = addActions.single;
      return transformAddAction(addAction);
    }
  }

  Future<List<CampaignAction>> _findActionsByPoiId(String poiId) async {
    var actionCacheList = campaignActionDatabase.getActionsWithPoiId(poiId);
    return actionCacheList;
  }

  void flushCache() async {
    if (_isflushing) return;
    try {
      _isflushing = true;
      notifyListeners();

      var posterApiService = GetIt.I<GrueneApiPosterService>();
      var doorApiService = GetIt.I<GrueneApiDoorService>();
      var flyerApiService = GetIt.I<GrueneApiFlyerService>();
      var routeApiService = GetIt.I<GrueneApiRouteService>();
      var areaApiService = GetIt.I<GrueneApiActionAreaService>();
      final allActions = await campaignActionDatabase.readAll();
      var failingPoiIds = <int>[];

      for (int i = 0; i < allActions.length; i++) {
        var action = allActions[i];

        if (failingPoiIds.contains(action.coalescedPoiId())) continue;

        updateIds(int newPoiId) async => await _updateIdsInCache(
          oldId: action.poiTempId,
          newId: newPoiId,
          startIndex: i + 1,
          allActions: allActions,
        );

        try {
          switch (action.actionType) {
            case CampaignActionType.addPoster:
              var model = action.getAsPosterCreate();
              var newPosterMarker = await posterApiService.createNewPoster(model);
              await updateIds(newPosterMarker.id!);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editPoster:
              var model = action.getAsPosterUpdate();
              await posterApiService.updatePoster(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.addDoor:
              var model = action.getAsDoorCreate();
              var newDoorMarker = await doorApiService.createNewDoor(model);
              await updateIds(newDoorMarker.id!);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editDoor:
              var model = action.getAsDoorUpdate();
              await doorApiService.updateDoor(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.addFlyer:
              var model = action.getAsFlyerCreate();
              var newFlyerMarker = await flyerApiService.createNewFlyer(model);
              await updateIds(newFlyerMarker.id!);
              campaignActionDatabase.delete(action.id!);
            case CampaignActionType.editFlyer:
              var model = action.getAsFlyerUpdate();
              await flyerApiService.updateFlyer(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.deleteDoor:
            case CampaignActionType.deletePoster:
            case CampaignActionType.deleteFlyer:
              await posterApiService.deletePoi(action.poiId!.toString());
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editRoute:
              var model = action.getAsRouteUpdate();
              await routeApiService.updateRoute(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editActionArea:
              var model = action.getAsActionAreaUpdate();
              await areaApiService.updateActionArea(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.unknown:
            case null:
              throw UnimplementedError();
          }
        } on ApiException catch (e) {
          if (_handleError(e, action.actionType!)) {
            campaignActionDatabase.delete(action.id!);
          } else {
            logger.e('Flushing Campaign Action (${action.actionType!.name}) failed: ${e.statusCode}');
            failingPoiIds.add(action.coalescedPoiId());
            continue;
          }
        }
        notifyListeners();
      }
    } finally {
      if (await getCachedActionCount() == 0) {
        MediaHelper.removeAllFiles();
      }
      if (_currentMapController != null) {
        _currentMapController!.resetMarkerItems();
      }
      _isflushing = false;
      notifyListeners();
    }
  }

  Future<void> _updateIdsInCache({
    required int oldId,
    required int newId,
    required List<CampaignAction> allActions,
    int startIndex = 0,
  }) async {
    await campaignActionDatabase.updatePoiId(oldId, newId);
    for (var j = startIndex; j < allActions.length; j++) {
      if (allActions[j].poiId == null) continue;
      if (allActions[j].poiId! == oldId) {
        allActions[j] = allActions[j].copyWith(poiId: newId);
      }
    }
  }

  Future<void> replaceAndFillUpMyPosterList(List<PosterListItemModel> myPosters) async {
    for (var i = 0; i < myPosters.length; i++) {
      final currentPoster = myPosters[i];
      var posterCacheList = await _findActionsByPoiId(currentPoster.id);
      var deletePosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.deletePoster).toList();
      if (deletePosterActions.isNotEmpty) {
        myPosters.remove(currentPoster);
        i--;
        continue;
      }
      var editPosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.editPoster).toList();
      if (editPosterActions.isNotEmpty) {
        var editPosterAction = editPosterActions.single;
        var posterListItem = editPosterAction.getPosterUpdateAsPosterListItem(currentPoster.createdAt);
        myPosters[i] = posterListItem;
      }
    }

    var newPosterCacheList = await campaignActionDatabase.readAllByActionType([CampaignActionType.addPoster.index]);
    for (var newPoster in newPosterCacheList) {
      var posterCacheList = await _findActionsByPoiId(newPoster.poiTempId.toString());
      var deletePosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.deletePoster).toList();
      if (deletePosterActions.isNotEmpty) {
        continue;
      }
      var editPosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.editPoster).toList();
      if (editPosterActions.isNotEmpty) {
        var editPosterAction = editPosterActions.single;
        var posterListItem = editPosterAction.getPosterUpdateAsPosterListItem(
          DateTime.fromMillisecondsSinceEpoch(newPoster.poiTempId),
        );
        myPosters.add(posterListItem);
        continue;
      }
      var addPosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.addPoster).toList();
      if (addPosterActions.isNotEmpty) {
        var addPosterAction = addPosterActions.single;
        var posterListItem = addPosterAction.getPosterCreateAsPosterListItem();
        myPosters.add(posterListItem);
        continue;
      }
    }
  }

  Future<PosterListItemModel> getPoiAsPosterListItem(String id, {DateTime? createdAt}) async {
    var posterCacheList = await _findActionsByPoiId(id);
    var editPosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.editPoster).toList();
    if (editPosterActions.isNotEmpty) {
      var editPosterAction = editPosterActions.single;
      var posterListItem = editPosterAction.getPosterUpdateAsPosterListItem(createdAt ?? DateTime.now());
      return posterListItem;
    }
    var addPosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.addPoster).toList();
    if (addPosterActions.isNotEmpty) {
      var addPosterAction = addPosterActions.single;
      var posterListItem = addPosterAction.getPosterCreateAsPosterListItem();
      return posterListItem;
    }
    throw UnimplementedError();
  }

  void setCurrentMapController(MapControllerSimplified controller) {
    _currentMapController = controller;
  }

  Future<bool> storeCacheOnDevice() async {
    var now = DateTime.now();
    var fileName = 'cache_dump_${now.getAsTimeStamp()}.json';

    final allActions = await campaignActionDatabase.readAll();
    var jsonContent = jsonEncode(allActions);
    List<int> byteList = utf8.encode(jsonContent);

    final params = SaveFileDialogParams(data: Uint8List.fromList(byteList), fileName: fileName);
    var result = await FlutterFileDialog.saveFile(params: params);
    return result != null;
  }

  bool _handleError(ApiException e, CampaignActionType currentAction) {
    var itemNotFoundActions = [
      PoiCacheType.door.getCacheEditAction(),
      PoiCacheType.door.getCacheDeleteAction(),
      PoiCacheType.flyer.getCacheEditAction(),
      PoiCacheType.flyer.getCacheDeleteAction(),
      PoiCacheType.poster.getCacheEditAction(),
      PoiCacheType.poster.getCacheDeleteAction(),
    ];
    if (e.statusCode == 404 && itemNotFoundActions.contains(currentAction)) {
      // POI seems to be deleted (before) and cannot be edited afterwards
      return true;
    }
    return false;
  }
}
