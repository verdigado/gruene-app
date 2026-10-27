part of '../converters.dart';

extension ProfileApiServicePaging on ProfileApiService {
  Future<List<CompletedChallenge>> getAllMyChallenges({
    required String profileId,
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    ChallengeSort? sorting,
    bool? onlyActiveCampaigns,
  }) async {
    var offset = 0;
    final pageSize = 200;
    var queryNextPage = true;
    List<CompletedChallenge> allPages = [];
    while (queryNextPage) {
      var currentPage = await getCompletedChallenges(
        profileId: profileId,
        challengeStatus: challengeStatus,
        campaignId: campaignId,
        sorting: sorting,
        onlyActiveCampaigns: onlyActiveCampaigns,
        offset: offset,
        limit: pageSize,
      );
      queryNextPage = currentPage.total > currentPage.offset + currentPage.data.length;
      offset += currentPage.data.length;
      allPages.addAll(currentPage.data);
    }
    return allPages;
  }
}
