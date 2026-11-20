part of '../converters.dart';

extension PoiCacheTypeActions on PoiCacheType {
  CampaignActionType getCacheAddAction() {
    switch (this) {
      case PoiCacheType.poster:
        return CampaignActionType.addPoster;
      case PoiCacheType.door:
        return CampaignActionType.addDoor;
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
      case PoiCacheType.route:
      case PoiCacheType.actionArea:
        throw UnimplementedError();
    }
  }
}
