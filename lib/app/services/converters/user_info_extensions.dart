part of '../converters.dart';

extension UserInfoExtension on UserInfo {
  static const realmRoleGNetzAdmin = 'gnetz-admin';

  static const campaignManagerKV = '7555238'; // Grünes Netz - Wahlatlas KV - Wahlkampfkoordinatorin
  static const campaignManagerLV = '7555237'; // Grünes Netz - Wahlatlas LV - Wahlkampfkoordinatorin
  static const campaignManagerBV = '7555236'; // Grünes Netz - Wahlatlas BV - Wahlkampfkoordinatorin

  bool isCampaignManager() {
    return groups
            ?.where((g) => g.contains('_'))
            .map((g) => g.split('_')[1])
            .any((x) => [campaignManagerBV, campaignManagerKV, campaignManagerLV].contains(x)) ??
        false;
  }

  bool isGnetzAdmin() {
    return roles?.contains(realmRoleGNetzAdmin) ?? false;
  }
}
