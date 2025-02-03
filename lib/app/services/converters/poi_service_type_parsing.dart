part of '../converters.dart';

extension PoiServiceTypeParsing on PoiServiceType {
  V1CampaignsPoisGetType transformToApiGetType() {
    switch (this) {
      case PoiServiceType.poster:
        return V1CampaignsPoisGetType.poster;
      case PoiServiceType.door:
        return V1CampaignsPoisGetType.house;
      case PoiServiceType.flyer:
        return V1CampaignsPoisGetType.flyerSpot;
    }
  }

  V1CampaignsPoisSelfGetType transformToApiSelfGetType() {
    switch (this) {
      case PoiServiceType.poster:
        return V1CampaignsPoisSelfGetType.poster;
      case PoiServiceType.door:
        return V1CampaignsPoisSelfGetType.house;
      case PoiServiceType.flyer:
        return V1CampaignsPoisSelfGetType.flyerSpot;
    }
  }

  CreatePoiType transformToApiCreateType() {
    switch (this) {
      case PoiServiceType.poster:
        return CreatePoiType.poster;
      case PoiServiceType.door:
        return CreatePoiType.house;
      case PoiServiceType.flyer:
        return CreatePoiType.flyerSpot;
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

  CampaignActionType getCacheDeleteAction() {
    switch (this) {
      case PoiServiceType.poster:
        return CampaignActionType.deletePoster;
      case PoiServiceType.door:
        return CampaignActionType.deleteDoor;
      case PoiServiceType.flyer:
        return CampaignActionType.deleteFlyer;
    }
  }

  CampaignActionType getCacheEditAction() {
    switch (this) {
      case PoiServiceType.poster:
        return CampaignActionType.editPoster;
      case PoiServiceType.door:
        return CampaignActionType.editDoor;
      case PoiServiceType.flyer:
        return CampaignActionType.editFlyer;
    }
  }

  CampaignActionType getCacheAddAction() {
    switch (this) {
      case PoiServiceType.poster:
        return CampaignActionType.addPoster;
      case PoiServiceType.door:
        return CampaignActionType.addDoor;
      case PoiServiceType.flyer:
        return CampaignActionType.addFlyer;
    }
  }
}
