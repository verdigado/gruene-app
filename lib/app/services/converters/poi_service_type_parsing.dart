part of '../converters.dart';

extension PoiCacheTypeParsing on PoiCacheType {
  CampaignActionType getCacheAddAction() {
    switch (this) {
      case PoiCacheType.poster:
        return CampaignActionType.addPoster;
      case PoiCacheType.door:
        return CampaignActionType.addDoor;
      case PoiCacheType.flyer:
        return CampaignActionType.addFlyer;
      case PoiCacheType.route:
      case PoiCacheType.actionArea:
        throw UnimplementedError();
    }
  }

  CampaignActionType getCacheDeleteAction() {
    switch (this) {
      case PoiCacheType.poster:
        return CampaignActionType.deletePoster;
      case PoiCacheType.door:
        return CampaignActionType.deleteDoor;
      case PoiCacheType.flyer:
        return CampaignActionType.deleteFlyer;
      case PoiCacheType.route:
      case PoiCacheType.actionArea:
        throw UnimplementedError();
    }
  }

  CampaignActionType getCacheEditAction() {
    switch (this) {
      case PoiCacheType.poster:
        return CampaignActionType.editPoster;
      case PoiCacheType.door:
        return CampaignActionType.editDoor;
      case PoiCacheType.flyer:
        return CampaignActionType.editFlyer;
      case PoiCacheType.actionArea:
        return CampaignActionType.editActionArea;
      case PoiCacheType.route:
        throw UnimplementedError();
    }
  }
}

extension PoiServiceTypeParsing on PoiServiceType {
  V1CampaignsPoisGetType transformToApiPoisGetType() {
    switch (this) {
      case PoiServiceType.poster:
        return V1CampaignsPoisGetType.poster;
      case PoiServiceType.door:
        return V1CampaignsPoisGetType.house;
      case PoiServiceType.flyer:
        return V1CampaignsPoisGetType.flyerSpot;
    }
  }

  V1CampaignsPoisSelfGetType transformToApiPoisSelfGetType() {
    switch (this) {
      case PoiServiceType.poster:
        return V1CampaignsPoisSelfGetType.poster;
      case PoiServiceType.door:
        return V1CampaignsPoisSelfGetType.house;
      case PoiServiceType.flyer:
        return V1CampaignsPoisSelfGetType.flyerSpot;
    }
  }

  CreatePoiType transformToApiCreatePoiType() {
    switch (this) {
      case PoiServiceType.poster:
        return CreatePoiType.poster;
      case PoiServiceType.door:
        return CreatePoiType.house;
      case PoiServiceType.flyer:
        return CreatePoiType.flyerSpot;
    }
  }

  V1CampaignsAreasGetType transformToApiAreasGetType() {
    switch (this) {
      case PoiServiceType.door:
        return V1CampaignsAreasGetType.house;
      case PoiServiceType.flyer:
        return V1CampaignsAreasGetType.flyerSpot;
      case PoiServiceType.poster:
        throw UnimplementedError();
    }
  }

  String getAsMarkerItemStatus(PosterStatus? posterStatus) {
    var typeName = name;
    switch (this) {
      case PoiServiceType.poster:
        String statusSuffix = '';
        if (posterStatus != null) statusSuffix = '_${posterStatus.name}';
        return '$typeName$statusSuffix';
      case PoiServiceType.door:
      case PoiServiceType.flyer:
        return typeName;
    }
  }

  V1CampaignsRoutesGetType transformToRoutesApiGetType() {
    switch (this) {
      case PoiServiceType.poster:
        return V1CampaignsRoutesGetType.poster;
      case PoiServiceType.door:
        return V1CampaignsRoutesGetType.house;
      case PoiServiceType.flyer:
        return V1CampaignsRoutesGetType.flyerSpot;
    }
  }

  PoiCacheType asPoiCacheType() {
    switch (this) {
      case PoiServiceType.poster:
        return PoiCacheType.poster;
      case PoiServiceType.door:
        return PoiCacheType.door;
      case PoiServiceType.flyer:
        return PoiCacheType.flyer;
    }
  }
}
