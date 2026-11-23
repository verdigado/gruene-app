part of '../converters.dart';

extension PoiCacheTypeActions on PoiCacheType {
  CampaignActionType getCacheAddAction() {
    switch (this) {
      case PoiCacheType.poster:
        return CampaignActionType.addPoster;
      case PoiCacheType.door:
        return CampaignActionType.addDoor;
      case PoiCacheType.stand:
        return CampaignActionType.addStand;
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
      case PoiCacheType.stand:
        return CampaignActionType.deleteStand;
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
      case PoiCacheType.stand:
        return CampaignActionType.editStand;
      case PoiCacheType.route:
      case PoiCacheType.actionArea:
        throw UnimplementedError();
    }
  }
}
