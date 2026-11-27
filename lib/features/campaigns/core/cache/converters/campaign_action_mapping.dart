part of '../converters.dart';

extension CampaignActionMapping on CampaignAction {
  int coalescedPoiId() => poiId ?? poiTempId;

  PosterCreateModel toPosterCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = PosterCreateModel.fromJson(data.convertLatLongField());
    return model;
  }

  PosterUpdateModel toPosterUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = PosterUpdateModel.fromJson(data.updateIdField(poiId!).convertLatLongField());

    return model;
  }

  DoorCreateModel toDoorCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = DoorCreateModel.fromJson(data.convertLatLongField());

    return model;
  }

  DoorUpdateModel toDoorUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = DoorUpdateModel.fromJson(data.updateIdField(poiId!).convertLatLongField());

    return model;
  }

  StandCreateModel toStandCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    return StandCreateModel.fromJson(data.convertLatLongField());
  }

  StandUpdateModel toStandUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    return StandUpdateModel.fromJson(data.updateIdField(poiId!).convertLatLongField());
  }

  /// Termin actions keep the stand as the person last saw it, for the map and the detail while offline.
  ({StandEntryCreateModel entry, StandDetailModel oldStandDetail}) toStandEntryCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    return (
      entry: StandEntryCreateModel.fromJson(data['entry'] as Map<String, dynamic>),
      oldStandDetail: StandDetailModel.fromJson(data['oldStandDetail'] as Map<String, dynamic>),
    );
  }

  ({StandEntryUpdateModel entry, StandDetailModel oldStandDetail}) toStandEntryUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    return (
      entry: StandEntryUpdateModel.fromJson(data['entry'] as Map<String, dynamic>),
      oldStandDetail: StandDetailModel.fromJson(data['oldStandDetail'] as Map<String, dynamic>),
    );
  }

  ({String entryId, StandDetailModel oldStandDetail}) toStandEntryDelete() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    return (
      entryId: data['entryId'] as String,
      oldStandDetail: StandDetailModel.fromJson(data['oldStandDetail'] as Map<String, dynamic>),
    );
  }

  /// The stand as last seen by the person, kept with a Termin action.
  StandDetailModel standOfEntryAction() => StandDetailModel.fromJson(
    (jsonDecode(serialized!) as Map<String, dynamic>)['oldStandDetail'] as Map<String, dynamic>,
  );

  PosterListItemModel toPosterListItemFromUpdate(DateTime originalCreatedAt) {
    var updateModel = toPosterUpdate().toPosterDetailModel();
    var lastPhoto = updateModel.latestPhoto();
    return PosterListItemModel(
      id: updateModel.id,
      thumbnailUrl: lastPhoto!.thumbnailUrl,
      imageUrl: lastPhoto.imageUrl,
      address: updateModel.address,
      status: updateModel.status.translatePosterStatus(),
      lastChangeStatus: t.campaigns.poster.updated,
      lastChangeDateTime: '${DateTime.fromMillisecondsSinceEpoch(poiTempId).toLocalDateTimeString()}*',
      createdAt: originalCreatedAt,
      isCached: true,
    );
  }

  PosterListItemModel toPosterListItemFromCreate() {
    var createModel = toPosterCreate().toPosterDetailModel(poiTempId.toString());
    var lastPhoto = createModel.latestPhoto();
    return PosterListItemModel(
      id: createModel.id,
      thumbnailUrl: lastPhoto?.thumbnailUrl,
      imageUrl: lastPhoto?.imageUrl,
      address: createModel.address,
      status: createModel.status.translatePosterStatus(),
      lastChangeStatus: t.campaigns.poster.updated,
      lastChangeDateTime: '${DateTime.fromMillisecondsSinceEpoch(poiTempId).toLocalDateTimeString()}*',
      createdAt: DateTime.fromMillisecondsSinceEpoch(poiTempId),
      isCached: true,
    );
  }

  RouteStatusUpdateModel toRouteStatusUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = RouteStatusUpdateModel.fromJson(data.updateIdField(poiId!));

    return model;
  }

  RouteAssignmentUpdateModel toRouteAssignmentUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = RouteAssignmentUpdateModel.fromJson(data.updateIdField(poiId!));

    return model;
  }

  ActionAreaStatusUpdateModel toActionAreaStatusUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = ActionAreaStatusUpdateModel.fromJson(data.updateIdField(poiId!));

    return model;
  }

  ActionAreaAssignmentUpdateModel toActionAreaAssignmentUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = ActionAreaAssignmentUpdateModel.fromJson(data.updateIdField(poiId!));

    return model;
  }
}
