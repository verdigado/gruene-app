part of '../converters.dart';

extension UserInfoExtension on UserRbacStructure {

  static const campaignManagerRoles = [
    // Wahlatlas
    '7555238', // Grünes Netz - Wahlatlas KV - Wahlkampfkoordinatorin
    '7555237', // Grünes Netz - Wahlatlas LV - Wahlkampfkoordinatorin
    '7555236', // Grünes Netz - Wahlatlas BV - Wahlkampfkoordinatorin
    // Wahlkampfkoordinator
    '5891385', // Landesverband GR - Koordinatorin Bundestagswahlkampf
    '7362861', // Landesverband GR - Koordinatorin Europawahlkampf
    '584949', // Landesverband GR - Koordinatorin Landtagswahlkampf
    '6849163', // Landesverband GR - Koordinatorin Kommunalwahlkampf
    '5878787', // Kreisverband GR - Koordinatorin Bundestagswahlkampf
    '7362866', // Kreisverband GR - Koordinatorin Europawahlkampf
    '585131', // Kreisverband GR - Koordinatorin Landtagswahlkampf
    '5878781', // Kreisverband GR - Koordinatorin Kommunalwahlkampf
    // Lokalkoordinator
    '9551523', // Haustür-WK-Lokal-Koordination Bundestagswahl
    '13474682', // Haustür-WK-Lokal-Koordination Europawahl
    '11798625', // Haustür-WK-Lokal-Koordination Landtagswahl
    '11798626', // Haustür-WK-Lokal-Koordination Landtagswahl
    '11798677', // Haustür-WK-Lokal-Koordination Kommunalwahl
  ];

  bool isCampaignManager() {
    return roles.map((r) => r.id).any((r) => campaignManagerRoles.contains(r));
  }

  bool isCampaignManagerInDivision(String division) {
    return roles
        .where((r) => campaignManagerRoles.contains(r.id))
        .any((r) => division.startsWith(r.divisionKey.stripRight('0')));
  }
}
