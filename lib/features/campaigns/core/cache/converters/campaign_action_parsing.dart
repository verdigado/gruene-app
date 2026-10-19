part of '../converters.dart';

extension CampaignActionParsing on CampaignAction {
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

  FlyerCreateModel toFlyerCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = FlyerCreateModel.fromJson(data.convertLatLongField());

    return model;
  }

  FlyerUpdateModel toFlyerUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = FlyerUpdateModel.fromJson(data.updateIdField(poiId!).convertLatLongField());

    return model;
  }

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
