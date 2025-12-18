part of '../converters.dart';

extension CampaignActionParsing on CampaignAction {
  int coalescedPoiId() => poiId ?? poiTempId;

  PosterCreateModel getAsPosterCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = PosterCreateModel.fromJson(data.convertLatLongField());
    return model;
  }

  PosterUpdateModel getAsPosterUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = PosterUpdateModel.fromJson(data.updateIdField(poiId!).convertLatLongField());

    return model;
  }

  DoorCreateModel getAsDoorCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = DoorCreateModel.fromJson(data.convertLatLongField());

    return model;
  }

  DoorUpdateModel getAsDoorUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = DoorUpdateModel.fromJson(data.updateIdField(poiId!).convertLatLongField());

    return model;
  }

  FlyerCreateModel getAsFlyerCreate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = FlyerCreateModel.fromJson(data.convertLatLongField());

    return model;
  }

  FlyerUpdateModel getAsFlyerUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = FlyerUpdateModel.fromJson(data.updateIdField(poiId!).convertLatLongField());

    return model;
  }

  PosterListItemModel getPosterUpdateAsPosterListItem(DateTime originalCreatedAt) {
    var updateModel = getAsPosterUpdate().transformToPosterDetailModel();
    var lastPhoto = updateModel.latestPhoto();
    return PosterListItemModel(
      id: updateModel.id,
      thumbnailUrl: lastPhoto!.thumbnailUrl,
      imageUrl: lastPhoto.imageUrl,
      address: updateModel.address,
      status: updateModel.status.translatePosterStatus(),
      lastChangeStatus: t.campaigns.poster.updated,
      lastChangeDateTime: '${DateTime.fromMillisecondsSinceEpoch(poiTempId).getAsLocalDateTimeString()}*',
      createdAt: originalCreatedAt,
      isCached: true,
    );
  }

  PosterListItemModel getPosterCreateAsPosterListItem() {
    var createModel = getAsPosterCreate().transformToPosterDetailModel(poiTempId.toString());
    var lastPhoto = createModel.latestPhoto();
    return PosterListItemModel(
      id: createModel.id,
      thumbnailUrl: lastPhoto!.thumbnailUrl,
      imageUrl: lastPhoto.imageUrl,
      address: createModel.address,
      status: createModel.status.translatePosterStatus(),
      lastChangeStatus: t.campaigns.poster.updated,
      lastChangeDateTime: '${DateTime.fromMillisecondsSinceEpoch(poiTempId).getAsLocalDateTimeString()}*',
      createdAt: DateTime.fromMillisecondsSinceEpoch(poiTempId),
      isCached: true,
    );
  }

  RouteUpdateModel getAsRouteUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = RouteUpdateModel.fromJson(data.updateIdField(poiId!));

    return model;
  }

  RouteAssignmentUpdateModel getAsRouteAssignmentUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = RouteAssignmentUpdateModel.fromJson(data.updateIdField(poiId!));

    return model;
  }

  ActionAreaUpdateModel getAsActionAreaUpdate() {
    var data = jsonDecode(serialized!) as Map<String, dynamic>;
    var model = ActionAreaUpdateModel.fromJson(data.updateIdField(poiId!));

    return model;
  }
}
