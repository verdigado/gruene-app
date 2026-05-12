part of '../converters.dart';

extension CampaignListExtension on List<Campaign> {
  List<Campaign> activeCampaigns() {
    return where((c) => c.status == CampaignStatus.active).toList();
  }

  List<Campaign> activeAndClosedCampaigns() {
    return where((c) => [CampaignStatus.active, CampaignStatus.closed].contains(c.status)).toList();
  }

  bool isCampaignActive(String? campaignId) {
    if (campaignId == null) return false;
    return activeCampaigns().any((c) => c.id == campaignId);
  }
}
