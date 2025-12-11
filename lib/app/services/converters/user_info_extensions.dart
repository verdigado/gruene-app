part of '../converters.dart';

extension UserInfoExtension on UserRbacStructure {
  static const campaignManagerKV = '7555238'; // Grünes Netz - Wahlatlas KV - Wahlkampfkoordinatorin
  static const campaignManagerLV = '7555237'; // Grünes Netz - Wahlatlas LV - Wahlkampfkoordinatorin
  static const campaignManagerBV = '7555236'; // Grünes Netz - Wahlatlas BV - Wahlkampfkoordinatorin

  bool isCampaignManager() {
    return roles.map((r) => r.id).any((r) => [campaignManagerBV, campaignManagerKV, campaignManagerLV].contains(r));
  }

  bool isCampaignManagerInDivision(String division) {
    return roles
        .where((r) => [campaignManagerBV, campaignManagerKV, campaignManagerLV].contains(r.id))
        .any((r) => division.startsWith(r.divisionKey));
  }
}
