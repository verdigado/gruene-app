import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/action_area/action_area_assignment_update_model.dart';
import 'package:gruene_app/app/models/campaigns/action_area/action_area_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/action_area/action_area_status_update_model.dart';
import 'package:gruene_app/app/models/campaigns/campaign_action.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_create_model.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_update_model.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_list_item_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_update_model.dart';
import 'package:gruene_app/app/models/campaigns/route/route_assignment_update_model.dart';
import 'package:gruene_app/app/models/campaigns/route/route_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/route/route_status_update_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/services/api/action_area_api_service.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/door_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/api/poster_api_service.dart';
import 'package:gruene_app/app/services/api/route_api_service.dart';
import 'package:gruene_app/app/services/api/stand_api_service.dart';
import 'package:gruene_app/app/services/campaign_action_database.dart';
import 'package:gruene_app/app/utils/extensions.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/core/cache/converters.dart';
import 'package:gruene_app/features/campaigns/core/converters.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/map_controller_simplified.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/turf.dart' as turf;

class CampaignActionCache extends ChangeNotifier {
  static CampaignActionCache? _instance;
  static bool _isflushing = false;
  var campaignActionDatabase = CampaignActionDatabase.instance;

  MapControllerSimplified? _currentMapController;

  CampaignActionCache._();

  factory CampaignActionCache() => _instance ??= CampaignActionCache._();

  bool get isFlushing => _isflushing;

  int _refusedActionCount = 0;

  /// Number of actions the API refused for good and that were dropped from the queue, not yet shown to the person.
  /// Which actions are dropped when refused is decided in [_handleError].
  int get refusedActionCount => _refusedActionCount;

  /// Returns [refusedActionCount] and resets it, once the person has been told.
  int takeRefusedActionCount() {
    final count = _refusedActionCount;
    _refusedActionCount = 0;
    return count;
  }

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

  Future<turf.Feature> storeNewPoi(PoiCacheType poiType, dynamic poiCreate) async {
    switch (poiType) {
      case PoiCacheType.poster:
        return await _addCreateAction<PosterCreateModel>(
          poiType: poiType,
          poi: poiCreate as PosterCreateModel,
          getJson: (poi) => poi.toJson(),
          getMarker: (poi, tempId) => poi.toVirtualPoiDetailModel(tempId).toFeature(),
        );
      case PoiCacheType.door:
        return await _addCreateAction<DoorCreateModel>(
          poiType: poiType,
          poi: poiCreate as DoorCreateModel,
          getJson: (poi) => poi.toJson(),
          getMarker: (poi, tempId) => poi.toVirtualPoiDetailModel(tempId).toFeature(),
        );
      case PoiCacheType.stand:
        return await _addCreateAction<StandCreateModel>(
          poiType: poiType,
          poi: poiCreate as StandCreateModel,
          getJson: (poi) => poi.toJson(),
          getMarker: (poi, tempId) => poi.toVirtualPoiDetailModel(tempId).toFeature(),
        );
      case PoiCacheType.route:
        throw UnimplementedError();
      case PoiCacheType.actionArea:
        throw UnimplementedError();
    }
  }

  Future<turf.Feature> _addCreateAction<T>({
    required PoiCacheType poiType,
    required T poi,
    required Map<String, dynamic> Function(T) getJson,
    required turf.Feature Function(T, int) getMarker,
  }) async {
    final action = CampaignAction(actionType: poiType.getCacheAddAction(), serialized: jsonEncode(getJson(poi)));
    await _appendActionToCache(action);
    return getMarker(poi, action.poiTempId);
  }

  Future<turf.Feature> deletePoi(PoiCacheType poiType, String poiId) async {
    if (poiType == PoiCacheType.stand) poiId = _resolveStandId(poiId);
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
    return _getDeleteMarker(poiType, action.poiId!).toFeature();
  }

  Future<turf.Feature> updatePoi(PoiCacheType poiType, dynamic poi) async {
    switch (poiType) {
      case PoiCacheType.poster:
        return await _addUpdateAction<PosterUpdateModel>(
          poiType: poiType,
          poi: poi as PosterUpdateModel,
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => action.toPosterUpdate().mergeWith(poiUpdate),
          getMarker: (poi) => poi.toVirtualPoiDetailModel().toFeature(),
        );
      case PoiCacheType.door:
        return await _addUpdateAction<DoorUpdateModel>(
          poiType: poiType,
          poi: poi as DoorUpdateModel,
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => poiUpdate,
          getMarker: (poi) => poi.toVirtualPoiDetailModel().toFeature(),
        );
      case PoiCacheType.stand:
        return await _addUpdateAction<StandUpdateModel>(
          poiType: poiType,
          poi: await _movePhotoChangesToQueuedStand(_resolveStandUpdate(poi as StandUpdateModel)),
          getId: (poi) => poi.id,
          getJson: (poi) => poi.toJson(),
          mergeUpdates: (action, poiUpdate) => action.toStandUpdate().mergeWith(poiUpdate),
          getMarker: (poi) => poi.toVirtualPoiDetailModel().toFeature(),
        );
      case PoiCacheType.route:
        if (poi.runtimeType == RouteStatusUpdateModel) {
          return await _addUpdateAction<RouteStatusUpdateModel>(
            poiType: poiType,
            poi: poi as RouteStatusUpdateModel,
            getId: (poi) => poi.id,
            getJson: (poi) => poi.toJson(),
            mergeUpdates: (action, poiUpdate) => poiUpdate,
            getMarker: (poi) => poi.toVirtualRouteDetailModel().toFeature(),
            getActionType: () => CampaignActionType.editRouteStatus,
          );
        } else if (poi.runtimeType == RouteAssignmentUpdateModel) {
          return await _addUpdateAction<RouteAssignmentUpdateModel>(
            poiType: poiType,
            poi: poi as RouteAssignmentUpdateModel,
            getId: (poi) => poi.id,
            getJson: (poi) => poi.toJson(),
            mergeUpdates: (action, poiUpdate) => poiUpdate,
            getMarker: (poi) => poi.toVirtualRouteDetailModel().toFeature(),
            getActionType: () => CampaignActionType.editRouteAssignment,
          );
        } else {
          throw ArgumentError('Unknown route update type');
        }
      case PoiCacheType.actionArea:
        if (poi.runtimeType == ActionAreaStatusUpdateModel) {
          return await _addUpdateAction<ActionAreaStatusUpdateModel>(
            poiType: poiType,
            poi: poi as ActionAreaStatusUpdateModel,
            getId: (poi) => poi.id,
            getJson: (poi) => poi.toJson(),
            mergeUpdates: (action, poiUpdate) => poiUpdate,
            getMarker: (poi) => poi.toVirtualActionAreaDetailModel().toFeature(),
            getActionType: () => CampaignActionType.editActionAreaStatus,
          );
        } else if (poi.runtimeType == ActionAreaAssignmentUpdateModel) {
          return await _addUpdateAction<ActionAreaAssignmentUpdateModel>(
            poiType: poiType,
            poi: poi as ActionAreaAssignmentUpdateModel,
            getId: (poi) => poi.id,
            getJson: (poi) => poi.toJson(),
            mergeUpdates: (action, poiUpdate) => poiUpdate,
            getMarker: (poi) => poi.toVirtualActionAreaDetailModel().toFeature(),
            getActionType: () => CampaignActionType.editActionAreaAssignment,
          );
        } else {
          throw ArgumentError('Unknown route update type');
        }
    }
  }

  /// The photos of a stand that is still in the queue are not in the API yet. Photos added to or removed from it are
  /// added to or removed from the queued stand instead, so that its later change does not delete a photo the API
  /// never had.
  Future<StandUpdateModel> _movePhotoChangesToQueuedStand(StandUpdateModel standUpdate) async {
    if (standUpdate.newPhotos.isEmpty && standUpdate.deletedPhotoIds.isEmpty) return standUpdate;
    final createAction = (await _findActionsByPoiId(standUpdate.id))
        .where((action) => action.actionType == CampaignActionType.addStand)
        .singleOrNull;
    if (createAction == null) return standUpdate;

    final standCreate = createAction.toStandCreate();
    final queuedStand = standCreate.withImageFileLocations([
      // queued photos have their local file as id
      ...standCreate.imageFileLocations.where((file) => !standUpdate.deletedPhotoIds.contains(file)),
      ...standUpdate.newPhotos.map((photo) => photo.imageUrl),
    ]);
    createAction.serialized = jsonEncode(queuedStand.toJson());
    await _updateAction(createAction);

    return StandUpdateModel(
      id: standUpdate.id,
      address: standUpdate.address,
      location: standUpdate.location,
      name: standUpdate.name,
      description: standUpdate.description,
      comment: standUpdate.comment,
      oldStandDetail: standUpdate.oldStandDetail.copyWith(photos: queuedStand.toQueuedPhotos()),
    );
  }

  Future<turf.Feature> _addUpdateAction<T>({
    required PoiCacheType poiType,
    required T poi,
    required String Function(T) getId,
    required Map<String, dynamic> Function(T) getJson,
    required T Function(CampaignAction, T) mergeUpdates,
    required turf.Feature Function(T) getMarker,
    CampaignActionType Function()? getActionType,
  }) async {
    var actionType = getActionType != null ? getActionType() : poiType.getCacheEditAction();
    var actions = (await _findActionsByPoiId(getId(poi))).where((x) => x.actionType == actionType);
    var action = actions.singleOrNull;
    if (action == null) {
      action = CampaignAction(
        poiId: int.parse(getId(poi)),
        actionType: actionType,
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

  PoiDetailModel _getDeleteMarker(PoiCacheType poiType, int id) {
    return PoiDetailModel.virtual(id: id, status: '${poiType.name}_deleted', location: LatLng(0, 0));
  }

  Future<CampaignAction?> getLatest(PoiCacheType poiType, String poiId) async {
    final poiCacheList = await campaignActionDatabase.readAllByActionTypeWithPoiId(
      poiId,
      _getActionsForCacheType(poiType),
    );
    poiCacheList.sort((a, b) => b.poiTempId.compareTo(a.poiTempId)); //reverse sort list by tempId (timestamped ID)
    return poiCacheList.firstOrNull;
  }

  Future<List<turf.Feature>> getLayerItems(PoiCacheType poiType) async {
    List<turf.Feature> markerItems = [];
    var poiActions = _getActionsForCacheType(poiType);
    final poiCacheList = await campaignActionDatabase.readAllByActionType(poiActions);
    poiCacheList.sort((a, b) => b.poiTempId.compareTo(a.poiTempId)); //reverse sort list by tempId (timestamped ID)
    for (var action in poiCacheList) {
      if (markerItems.any((m) => m.id == action.coalescedPoiId())) continue;
      switch (action.actionType) {
        case CampaignActionType.addPoster:
          var model = action.toPosterCreate();
          markerItems.add(model.toVirtualPoiDetailModel(action.poiTempId).toFeature());
        case CampaignActionType.editPoster:
          var model = action.toPosterUpdate();
          markerItems.add(model.toVirtualPoiDetailModel().toFeature());
        case CampaignActionType.deletePoster:
          var model = _getDeleteMarker(PoiCacheType.poster, action.poiId!);
          markerItems.add(model.toFeature());

        case CampaignActionType.addDoor:
          var model = action.toDoorCreate();
          markerItems.add(model.toVirtualPoiDetailModel(action.poiTempId).toFeature());
        case CampaignActionType.editDoor:
          var model = action.toDoorUpdate();
          markerItems.add(model.toVirtualPoiDetailModel().toFeature());
        case CampaignActionType.deleteDoor:
          var model = _getDeleteMarker(PoiCacheType.door, action.poiId!);
          markerItems.add(model.toFeature());

        case CampaignActionType.addStand:
          var model = action.toStandCreate();
          markerItems.add(model.toVirtualPoiDetailModel(action.poiTempId).toFeature());
        case CampaignActionType.editStand:
          var model = action.toStandUpdate();
          markerItems.add(model.toVirtualPoiDetailModel().toFeature());
        case CampaignActionType.deleteStand:
          var model = _getDeleteMarker(PoiCacheType.stand, action.poiId!);
          markerItems.add(model.toFeature());
        case CampaignActionType.addStandEntry:
        case CampaignActionType.editStandEntry:
        case CampaignActionType.deleteStandEntry:
          // the stand of a Termin is shown where the person last saw it
          var model = PoiDetailModel.virtual(
            id: action.poiId,
            status: PoiServiceType.stand.name,
            location: action.standOfEntryAction().location,
          );
          markerItems.add(model.toFeature());

        case CampaignActionType.editRouteStatus:
          var model = action.toRouteStatusUpdate();
          markerItems.add(model.toVirtualRouteDetailModel().toFeature());
        case CampaignActionType.editRouteAssignment:
          var model = action.toRouteAssignmentUpdate();
          markerItems.add(model.toVirtualRouteDetailModel().toFeature());

        case CampaignActionType.editActionAreaStatus:
          var model = action.toActionAreaStatusUpdate();
          markerItems.add(model.toVirtualActionAreaDetailModel().toFeature());
        case CampaignActionType.editActionAreaAssignment:
          var model = action.toActionAreaAssignmentUpdate();
          markerItems.add(model.toVirtualActionAreaDetailModel().toFeature());

        // flyer actions are converted to door actions when the database is upgraded
        // ignore: deprecated_member_use_from_same_package
        case CampaignActionType.addFlyer || CampaignActionType.editFlyer || CampaignActionType.deleteFlyer:
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

    switch (poiType) {
      case PoiCacheType.poster:
      case PoiCacheType.door:
        {
          return [
            getValueSafe(() => poiType.getCacheAddAction()),
            getValueSafe(() => poiType.getCacheEditAction()),
            getValueSafe(() => poiType.getCacheDeleteAction()),
          ].where((x) => x != null).cast<int>().toList();
        }
      case PoiCacheType.stand:
        return [
          CampaignActionType.addStand,
          CampaignActionType.editStand,
          CampaignActionType.deleteStand,
          CampaignActionType.addStandEntry,
          CampaignActionType.editStandEntry,
          CampaignActionType.deleteStandEntry,
        ].map((a) => a.index).toList();
      case PoiCacheType.actionArea:
        return [
          CampaignActionType.editActionAreaStatus,
          CampaignActionType.editActionAreaAssignment,
        ].map((a) => a.index).toList();
      case PoiCacheType.route:
        return [
          CampaignActionType.editRouteStatus,
          CampaignActionType.editRouteAssignment,
        ].map((a) => a.index).toList();
    }
  }

  Future<PosterDetailModel> getPoiAsPosterDetail(String poiId) async {
    var detailModel = await _getPoiDetail<PosterDetailModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.addPoster,
      editActionFilter: CampaignActionType.editPoster,
      transformEditAction: (action) => action.toPosterUpdate().toPosterDetailModel(),
      transformAddAction: (action) => action.toPosterCreate().toPosterDetailModel(poiId),
    );
    return detailModel;
  }

  Future<DoorDetailModel> getPoiAsDoorDetail(String poiId) async {
    var detailModel = await _getPoiDetail<DoorDetailModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.addDoor,
      editActionFilter: CampaignActionType.editDoor,
      transformEditAction: (action) => action.toDoorUpdate().toDoorDetailModel(),
      transformAddAction: (action) => action.toDoorCreate().toDoorDetailModel(poiId),
    );
    return detailModel;
  }

  /// The stand with all changes still in the queue. Its [StandDetailModel.flyerCountTotal] stays the last one
  /// from the API; the detail shows the provisional [StandDetailModel.displayedFlyerTotal] until the queue is synced.
  Future<StandDetailModel> getPoiAsStandDetail(String standId) async {
    final poiId = _resolveStandId(standId);
    final actions = await _findActionsByPoiId(poiId);
    final localEntryIds = <String>{};
    StandDetailModel? stand;
    for (final action in actions) {
      switch (action.actionType) {
        case CampaignActionType.addStand:
          final firstEntryId = _localEntryId(action);
          localEntryIds.add(firstEntryId);
          stand = action.toStandCreate().toStandDetailModel(poiId, firstEntryId: firstEntryId);
        case CampaignActionType.editStand:
          // a change of the stand itself: its Termine are those built so far, as a queued Termin change is updated in
          // place and can be newer than the Termine in this change's snapshot
          final edited = action.toStandUpdate().toStandDetailModel();
          stand = stand == null ? edited : edited.copyWith(entries: stand.entries);
        case CampaignActionType.addStandEntry:
          final (:entry, :oldStandDetail) = action.toStandEntryCreate();
          final entryId = _localEntryId(action);
          localEntryIds.add(entryId);
          stand = (stand ?? oldStandDetail).withEntry(entry.toStandEntryModel(entryId));
        case CampaignActionType.editStandEntry:
          final (:entry, :oldStandDetail) = action.toStandEntryUpdate();
          stand = (stand ?? oldStandDetail).withEntry(entry.toStandEntryModel());
        case CampaignActionType.deleteStandEntry:
          final (:entryId, :oldStandDetail) = action.toStandEntryDelete();
          stand = (stand ?? oldStandDetail).withoutEntry(entryId);
        default:
          break;
      }
    }
    if (stand == null) throw StateError('Stand $poiId is not in the queue');

    // a stand seen earlier can still list a queued Termin that was deleted again in the meantime
    final entries = stand.entries.where((e) => !_isLocalEntryId(e.id) || localEntryIds.contains(e.id)).toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return stand.copyWith(entries: entries, isCached: true);
  }

  /// Queues a new Termin for a stand, which may itself still be in the queue.
  Future<turf.Feature> addStandEntry(String standId, StandEntryCreateModel entry, StandDetailModel standSeen) async {
    standId = _resolveStandId(standId);
    final oldStandDetail = _resolveStand(standSeen);
    await _appendActionToCache(
      CampaignAction(
        poiId: int.parse(standId),
        actionType: CampaignActionType.addStandEntry,
        serialized: jsonEncode({'entry': entry.toJson(), 'oldStandDetail': oldStandDetail.toJson()}),
      ),
    );
    return oldStandDetail.toVirtualPoiDetailModel().toFeature();
  }

  /// Queues a change of a Termin. A Termin that is still in the queue is changed there.
  Future<turf.Feature> updateStandEntry(
    String standId,
    StandEntryUpdateModel entrySeen,
    StandDetailModel standSeen,
  ) async {
    standId = _resolveStandId(standId);
    final oldStandDetail = _resolveStand(standSeen);
    final entry = StandEntryUpdateModel(
      entryId: _resolveEntryId(entrySeen.entryId),
      startAt: entrySeen.startAt,
      endAt: entrySeen.endAt,
      flyerCount: entrySeen.flyerCount,
    );
    final actions = await _findActionsByPoiId(standId);
    final queuedAction = _findQueuedEntryAction(actions, entry.entryId);
    final values = StandEntryCreateModel(startAt: entry.startAt, endAt: entry.endAt, flyerCount: entry.flyerCount);

    if (queuedAction?.actionType == CampaignActionType.addStand) {
      // the first Termin of a stand that is still in the queue
      final standCreate = queuedAction!.toStandCreate();
      queuedAction.serialized = jsonEncode(standCreate.withFirstEntry(values).toJson());
      await _updateAction(queuedAction);
    } else if (queuedAction != null) {
      queuedAction.serialized = jsonEncode({'entry': values.toJson(), 'oldStandDetail': oldStandDetail.toJson()});
      await _updateAction(queuedAction);
    } else {
      final serialized = jsonEncode({'entry': entry.toJson(), 'oldStandDetail': oldStandDetail.toJson()});
      final previousEdit = actions
          .where((a) => a.actionType == CampaignActionType.editStandEntry)
          .where((a) => a.toStandEntryUpdate().entry.entryId == entry.entryId)
          .firstOrNull;
      if (previousEdit != null) {
        previousEdit.serialized = serialized;
        await _updateAction(previousEdit);
      } else {
        await _appendActionToCache(
          CampaignAction(
            poiId: int.parse(standId),
            actionType: CampaignActionType.editStandEntry,
            serialized: serialized,
          ),
        );
      }
    }
    notifyListeners();
    return oldStandDetail.toVirtualPoiDetailModel().toFeature();
  }

  /// Queues the deletion of a Termin. A Termin that is still in the queue is removed from it.
  Future<turf.Feature> deleteStandEntry(String standId, String entryIdSeen, StandDetailModel standSeen) async {
    standId = _resolveStandId(standId);
    final oldStandDetail = _resolveStand(standSeen);
    final entryId = _resolveEntryId(entryIdSeen);
    final actions = await _findActionsByPoiId(standId);
    final queuedAction = _findQueuedEntryAction(actions, entryId);

    if (queuedAction?.actionType == CampaignActionType.addStand) {
      // the first Termin of a queued stand: the next queued Termin takes its place
      final nextEntryAction = actions.where((a) => a.actionType == CampaignActionType.addStandEntry).firstOrNull;
      if (nextEntryAction == null) {
        throw StateError('The last Termin of a stand cannot be deleted, the stand has to be deleted instead');
      }
      final standCreate = queuedAction!.toStandCreate();
      queuedAction.serialized = jsonEncode(
        standCreate.withFirstEntry(nextEntryAction.toStandEntryCreate().entry).toJson(),
      );
      await _updateAction(queuedAction);
      await campaignActionDatabase.delete(nextEntryAction.id!);
    } else if (queuedAction != null) {
      await campaignActionDatabase.delete(queuedAction.id!);
    } else {
      final previousEdits = actions
          .where((a) => a.actionType == CampaignActionType.editStandEntry)
          .where((a) => a.toStandEntryUpdate().entry.entryId == entryId);
      for (final edit in previousEdits) {
        await campaignActionDatabase.delete(edit.id!);
      }
      await campaignActionDatabase.create(
        CampaignAction(
          poiId: int.parse(standId),
          actionType: CampaignActionType.deleteStandEntry,
          serialized: jsonEncode({'entryId': entryId, 'oldStandDetail': oldStandDetail.toJson()}),
        ),
      );
    }
    notifyListeners();
    return oldStandDetail.toVirtualPoiDetailModel().toFeature();
  }

  /// Termine that are still in the queue get an id from their queued action, which cannot clash with API ids.
  static const _localEntryIdPrefix = 'local-';

  String _localEntryId(CampaignAction action) => '$_localEntryIdPrefix${action.id}';

  bool _isLocalEntryId(String entryId) => entryId.startsWith(_localEntryIdPrefix);

  /// The queued action that creates the Termin with this id: an `addStandEntry`, or the `addStand` of its first Termin.
  /// Throws [OutdatedStandException] if the id is a local one whose action is gone, as the API cannot know that
  /// Termin by this id.
  CampaignAction? _findQueuedEntryAction(List<CampaignAction> actions, String entryId) {
    if (!_isLocalEntryId(entryId)) return null;
    final actionId = int.parse(entryId.substring(_localEntryIdPrefix.length));
    final action = actions
        .where((a) => a.id == actionId)
        .where((a) => a.actionType == CampaignActionType.addStand || a.actionType == CampaignActionType.addStandEntry)
        .singleOrNull;
    if (action == null) throw OutdatedStandException(entryId);
    return action;
  }

  /// Ids the API gave to stands and Termine sent from the queue, by their temporary id. A stand detail opened before
  /// the sync still shows the temporary ids; changes made there are queued with the ids from the API instead.
  final _syncedStandIds = <String, String>{};
  final _syncedEntryIds = <String, String>{};

  String _resolveStandId(String standId) => _syncedStandIds[standId] ?? standId;

  String _resolveEntryId(String entryId) => _syncedEntryIds[entryId] ?? entryId;

  StandDetailModel _resolveStand(StandDetailModel stand) => stand.copyWith(
    id: _resolveStandId(stand.id),
    entries: [
      for (final e in stand.entries)
        StandEntryModel(id: _resolveEntryId(e.id), startAt: e.startAt, endAt: e.endAt, flyerCount: e.flyerCount),
    ],
  );

  StandUpdateModel _resolveStandUpdate(StandUpdateModel update) => StandUpdateModel(
    id: _resolveStandId(update.id),
    address: update.address,
    location: update.location,
    name: update.name,
    description: update.description,
    comment: update.comment,
    oldStandDetail: _resolveStand(update.oldStandDetail),
    deletedPhotoIds: update.deletedPhotoIds,
    newPhotos: update.newPhotos,
  );

  /// Remembers the id the API gave to a Termin sent from the queue: the one in [stand] that the person had not seen
  /// before and that has the times of [entry].
  void _rememberSyncedEntryId(
    CampaignAction action,
    StandDetailModel stand,
    StandEntryCreateModel entry,
    StandDetailModel standSeen,
  ) {
    final knownIds = {...standSeen.entries.map((e) => e.id), ..._syncedEntryIds.values};
    final created = stand.entries
        .where((e) => !knownIds.contains(e.id))
        .where((e) => e.startAt.isAtSameMomentAs(entry.startAt) && e.endAt.isAtSameMomentAs(entry.endAt))
        .firstOrNull;
    if (created != null) _syncedEntryIds[_localEntryId(action)] = created.id;
  }

  Future<RouteStatusUpdateModel> getPoiAsRouteDetail(String poiId) async {
    var detailModel = await _getPoiDetail<RouteStatusUpdateModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.editRouteStatus,
      editActionFilter: CampaignActionType.editRouteStatus,
      transformEditAction: (action) => action.toRouteStatusUpdate(),
      transformAddAction: (action) => action.toRouteStatusUpdate(),
    );
    return detailModel;
  }

  Future<RouteAssignmentUpdateModel> getPoiAsRouteAssignment(String poiId) async {
    var detailModel = await _getPoiDetail<RouteAssignmentUpdateModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.editRouteAssignment,
      editActionFilter: CampaignActionType.editRouteAssignment,
      transformEditAction: (action) => action.toRouteAssignmentUpdate(),
      transformAddAction: (action) => action.toRouteAssignmentUpdate(),
    );
    return detailModel;
  }

  Future<RouteDetailModel> getLatestRouteDetail(String poiId) async {
    var action = await getLatest(PoiCacheType.route, poiId);
    if (action == null) throw Exception('Route not found in Cache');
    switch (action.actionType) {
      case CampaignActionType.editRouteAssignment:
        return action.toRouteAssignmentUpdate().toVirtualRouteDetailModel();
      case CampaignActionType.editRouteStatus:
        return action.toRouteStatusUpdate().toVirtualRouteDetailModel();
      case CampaignActionType.unknown:
      case CampaignActionType.addPoster:
      case CampaignActionType.editPoster:
      case CampaignActionType.deletePoster:
      case CampaignActionType.addDoor:
      case CampaignActionType.editDoor:
      case CampaignActionType.deleteDoor:
      // ignore: deprecated_member_use_from_same_package
      case CampaignActionType.addFlyer || CampaignActionType.editFlyer || CampaignActionType.deleteFlyer:
      case CampaignActionType.editActionAreaStatus:
      case CampaignActionType.editActionAreaAssignment:
      case CampaignActionType.addStand:
      case CampaignActionType.editStand:
      case CampaignActionType.deleteStand:
      case CampaignActionType.addStandEntry:
      case CampaignActionType.editStandEntry:
      case CampaignActionType.deleteStandEntry:
      case null:
        throw UnimplementedError();
    }
  }

  Future<ActionAreaDetailModel> getLatestActionAreaDetail(String poiId) async {
    var action = await getLatest(PoiCacheType.actionArea, poiId);
    if (action == null) throw Exception('Area not found in Cache');
    switch (action.actionType) {
      case CampaignActionType.editActionAreaAssignment:
        return action.toActionAreaAssignmentUpdate().toVirtualActionAreaDetailModel();
      case CampaignActionType.editActionAreaStatus:
        return action.toActionAreaStatusUpdate().toVirtualActionAreaDetailModel();
      case CampaignActionType.unknown:
      case CampaignActionType.addPoster:
      case CampaignActionType.editPoster:
      case CampaignActionType.deletePoster:
      case CampaignActionType.addDoor:
      case CampaignActionType.editDoor:
      case CampaignActionType.deleteDoor:
      // ignore: deprecated_member_use_from_same_package
      case CampaignActionType.addFlyer || CampaignActionType.editFlyer || CampaignActionType.deleteFlyer:
      case CampaignActionType.editRouteStatus:
      case CampaignActionType.editRouteAssignment:
      case CampaignActionType.addStand:
      case CampaignActionType.editStand:
      case CampaignActionType.deleteStand:
      case CampaignActionType.addStandEntry:
      case CampaignActionType.editStandEntry:
      case CampaignActionType.deleteStandEntry:
      case null:
        throw UnimplementedError();
    }
  }

  Future<ActionAreaDetailModel> getPoiAsActionAreaDetail(String poiId) async {
    var detailModel = await _getPoiDetail<ActionAreaDetailModel>(
      poiId: poiId,
      addActionFilter: CampaignActionType.editActionAreaStatus,
      editActionFilter: CampaignActionType.editActionAreaStatus,
      transformEditAction: (action) => action.toActionAreaStatusUpdate().toVirtualActionAreaDetailModel(),
      transformAddAction: (action) => action.toActionAreaStatusUpdate().toVirtualActionAreaDetailModel(),
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

  Future<void> flushCache() async {
    if (_isflushing) return;
    try {
      _isflushing = true;
      notifyListeners();

      var posterApiService = GetIt.I<PosterApiService>();
      var doorApiService = GetIt.I<DoorApiService>();
      var standApiService = GetIt.I<StandApiService>();
      var routeApiService = GetIt.I<RouteApiService>();
      var areaApiService = GetIt.I<ActionAreaApiService>();
      final allActions = await campaignActionDatabase.readAll();
      var failingPoiIds = <int>[];
      // queued stands the API refused to create: their later changes and Termine cannot be sent either
      var refusedQueuedStandIds = <int>{};

      for (int i = 0; i < allActions.length; i++) {
        var action = allActions[i];

        if (failingPoiIds.contains(action.coalescedPoiId())) continue;

        if (_standActions.contains(action.actionType) && refusedQueuedStandIds.contains(action.coalescedPoiId())) {
          await campaignActionDatabase.delete(action.id!);
          _refusedActionCount++;
          notifyListeners();
          continue;
        }

        updateIds(int newPoiId) async => await _updateIdsInCache(
          oldId: action.poiTempId,
          newId: newPoiId,
          startIndex: i + 1,
          allActions: allActions,
        );

        try {
          switch (action.actionType) {
            case CampaignActionType.addPoster:
              var model = action.toPosterCreate();
              var newPosterMarker = await posterApiService.createNewPoster(model);
              await updateIds(newPosterMarker.id!);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editPoster:
              var model = action.toPosterUpdate();
              await posterApiService.updatePoster(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.addDoor:
              var model = action.toDoorCreate();
              var newDoorMarker = await doorApiService.createNewDoor(model);
              await updateIds(newDoorMarker.id!);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editDoor:
              var model = action.toDoorUpdate();
              await doorApiService.updateDoor(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.deleteDoor:
              await doorApiService.deletePoi(action.poiId!.toString());
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.deletePoster:
              await posterApiService.deletePoi(action.poiId!.toString());
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.addStand:
              var model = action.toStandCreate();
              var newStand = await standApiService.createNewStand(model);
              _syncedStandIds[action.poiTempId.toString()] = newStand.id;
              // a new stand has only its first Termin
              final firstEntry = newStand.entries.singleOrNull;
              if (firstEntry != null) _syncedEntryIds[_localEntryId(action)] = firstEntry.id;
              await updateIds(int.parse(newStand.id));
              await _queuePhotosOfCreatedStand(model, newStand, allActions, startIndex: i + 1);
              await campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editStand:
              var model = action.toStandUpdate();
              await standApiService.updateStand(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.deleteStand:
              await standApiService.deletePoi(action.poiId!.toString());
              campaignActionDatabase.delete(action.id!);

            // Termin actions refer to their stand by poiId, which is updated once a queued stand is created
            case CampaignActionType.addStandEntry:
              final (:entry, :oldStandDetail) = action.toStandEntryCreate();
              final stand = await standApiService.addStandEntry(action.poiId!.toString(), entry);
              _rememberSyncedEntryId(action, stand, entry, oldStandDetail);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editStandEntry:
              await standApiService.updateStandEntry(action.poiId!.toString(), action.toStandEntryUpdate().entry);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.deleteStandEntry:
              await standApiService.deleteStandEntry(action.poiId!.toString(), action.toStandEntryDelete().entryId);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editRouteStatus:
              var model = action.toRouteStatusUpdate();
              await routeApiService.updateRouteStatus(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editRouteAssignment:
              var model = action.toRouteAssignmentUpdate();
              await routeApiService.updateRouteAssignemnt(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editActionAreaStatus:
              var model = action.toActionAreaStatusUpdate();
              await areaApiService.updateActionAreaStatus(model);
              campaignActionDatabase.delete(action.id!);

            case CampaignActionType.editActionAreaAssignment:
              var model = action.toActionAreaAssignmentUpdate();
              await areaApiService.updateActionAreaAssignemnt(model);
              campaignActionDatabase.delete(action.id!);

            // flyer actions are converted to door actions when the database is upgraded
            // ignore: deprecated_member_use_from_same_package
            case CampaignActionType.addFlyer || CampaignActionType.editFlyer || CampaignActionType.deleteFlyer:
            case CampaignActionType.unknown:
            case null:
              throw UnimplementedError();
          }
        } on ApiException catch (e) {
          switch (_handleError(e, action.actionType!)) {
            case _SyncFailure.drop:
              campaignActionDatabase.delete(action.id!);
            case _SyncFailure.dropAndReport:
              logger.w('Campaign Action (${action.actionType!.name}) refused by the API: ${e.statusCode}');
              await campaignActionDatabase.delete(action.id!);
              _refusedActionCount++;
              // createNewStand only creates the stand (its photos follow as an editStand), so a refused addStand
              // means the stand does not exist on the server
              if (action.actionType == CampaignActionType.addStand) refusedQueuedStandIds.add(action.poiTempId);
            case _SyncFailure.retry:
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

  /// Hands the photos of a stand just created from the queue to a change of that stand, which uploads them later in
  /// the same sync. A failed upload is then retried as that change, without creating the stand a second time.
  /// A change of the stand already queued gets the photos; otherwise a new one is queued and added to [allActions].
  Future<void> _queuePhotosOfCreatedStand(
    StandCreateModel standCreate,
    StandDetailModel createdStand,
    List<CampaignAction> allActions, {
    required int startIndex,
  }) async {
    if (standCreate.imageFileLocations.isEmpty) return;
    final photoUpload = StandUpdateModel(
      id: createdStand.id,
      address: createdStand.address,
      location: createdStand.location,
      name: createdStand.name,
      description: createdStand.description,
      comment: createdStand.comment,
      oldStandDetail: createdStand,
      newPhotos: standCreate.toQueuedPhotos(),
    );

    final index = allActions.indexWhere(
      (a) => a.actionType == CampaignActionType.editStand && a.poiId.toString() == createdStand.id,
      startIndex,
    );
    if (index >= 0) {
      final queuedChange = allActions[index];
      // the queued change is newer, so its values win; the photos come first, as they were added first
      final merged = photoUpload.mergeWith(queuedChange.toStandUpdate());
      // its snapshot was taken before the sync and still has the temporary id of the first Termin, whose action is
      // gone now; the stand as created by the API has the real Termin ids
      final withCreatedStand = StandUpdateModel(
        id: merged.id,
        address: merged.address,
        location: merged.location,
        name: merged.name,
        description: merged.description,
        comment: merged.comment,
        oldStandDetail: createdStand,
        deletedPhotoIds: merged.deletedPhotoIds,
        newPhotos: merged.newPhotos,
      );
      queuedChange.serialized = jsonEncode(withCreatedStand.toJson());
      await _updateAction(queuedChange);
    } else {
      final action = await campaignActionDatabase.create(
        CampaignAction(
          poiId: int.parse(createdStand.id),
          actionType: CampaignActionType.editStand,
          serialized: jsonEncode(photoUpload.toJson()),
        ),
      );
      allActions.add(action);
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
        var posterListItem = editPosterAction.toPosterListItemFromUpdate(currentPoster.createdAt);
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
        var posterListItem = editPosterAction.toPosterListItemFromUpdate(
          DateTime.fromMillisecondsSinceEpoch(newPoster.poiTempId),
        );
        myPosters.add(posterListItem);
        continue;
      }
      var addPosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.addPoster).toList();
      if (addPosterActions.isNotEmpty) {
        var addPosterAction = addPosterActions.single;
        var posterListItem = addPosterAction.toPosterListItemFromCreate();
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
      var posterListItem = editPosterAction.toPosterListItemFromUpdate(createdAt ?? DateTime.now());
      return posterListItem;
    }
    var addPosterActions = posterCacheList.where((p) => p.actionType == CampaignActionType.addPoster).toList();
    if (addPosterActions.isNotEmpty) {
      var addPosterAction = addPosterActions.single;
      var posterListItem = addPosterAction.toPosterListItemFromCreate();
      return posterListItem;
    }
    throw UnimplementedError();
  }

  void setCurrentMapController(MapControllerSimplified controller) {
    _currentMapController = controller;
  }

  Future<bool> storeCacheOnDevice() async {
    var now = DateTime.now();
    var fileName = 'cache_dump_${now.toTimeStamp()}.json';

    final allActions = await campaignActionDatabase.readAll();
    var jsonContent = jsonEncode(allActions);
    List<int> byteList = utf8.encode(jsonContent);

    final params = SaveFileDialogParams(data: Uint8List.fromList(byteList), fileName: fileName);
    var result = await FlutterFileDialog.saveFile(params: params);
    return result != null;
  }

  static const _standActions = [
    CampaignActionType.addStand,
    CampaignActionType.editStand,
    CampaignActionType.deleteStand,
    CampaignActionType.addStandEntry,
    CampaignActionType.editStandEntry,
    CampaignActionType.deleteStandEntry,
  ];

  /// Actions that are dropped and reported when the API refuses them for good (see [_refusedStatusCodes]).
  /// Other actions are retried with the next sync; further pin types can opt in here.
  static const _actionsDroppedWhenRefused = _standActions;

  /// Status codes with which the API refuses an action for good, so a retry cannot help:
  /// 400 validation (e.g. flyers for a Termin after today), 403 no write access, 409 e.g. not a stand or no photos.
  static const _refusedStatusCodes = [400, 403, 409];

  _SyncFailure _handleError(ApiException e, CampaignActionType currentAction) {
    var itemNotFoundActions = [
      PoiCacheType.door.getCacheEditAction(),
      PoiCacheType.door.getCacheDeleteAction(),
      PoiCacheType.poster.getCacheEditAction(),
      PoiCacheType.poster.getCacheDeleteAction(),
      PoiCacheType.stand.getCacheEditAction(),
      PoiCacheType.stand.getCacheDeleteAction(),
      // the stand or the Termin was deleted on the server in the meantime
      CampaignActionType.addStandEntry,
      CampaignActionType.editStandEntry,
      CampaignActionType.deleteStandEntry,
    ];
    if (e.statusCode == 404 && itemNotFoundActions.contains(currentAction)) {
      // POI seems to be deleted (before) and cannot be edited afterwards
      return _SyncFailure.drop;
    }
    if (_refusedStatusCodes.contains(e.statusCode) && _actionsDroppedWhenRefused.contains(currentAction)) {
      return _SyncFailure.dropAndReport;
    }
    return _SyncFailure.retry;
  }
}

/// A Termin was changed in a stand detail opened before the sync, and the id the API gave it is unknown.
/// The change is not queued; the stand has to be opened again.
class OutdatedStandException implements Exception {
  final String entryId;

  OutdatedStandException(this.entryId);

  @override
  String toString() => 'OutdatedStandException: Termin $entryId was synced, its id from the API is unknown';
}

enum _SyncFailure {
  /// Keep the action and try again with the next sync.
  retry,

  /// Remove the action silently, e.g. a change of a pin deleted in the meantime.
  drop,

  /// Remove the action and tell the person that the change was not saved.
  dropAndReport,
}
