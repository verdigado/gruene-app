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
      case PoiCacheType.route:
      case PoiCacheType.actionArea:
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

  AreaType transformToApiAreasGetType() {
    switch (this) {
      case PoiServiceType.door:
        return AreaType.house;
      case PoiServiceType.flyer:
        return AreaType.flyerSpot;
      case PoiServiceType.poster:
        return AreaType.poster;
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

  RouteType transformToRoutesApiGetType() {
    switch (this) {
      case PoiServiceType.poster:
        return RouteType.poster;
      case PoiServiceType.door:
        return RouteType.house;
      case PoiServiceType.flyer:
        return RouteType.flyerSpot;
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
