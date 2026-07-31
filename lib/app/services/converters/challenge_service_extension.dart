part of '../converters.dart';

enum ChallengeSort { userDivision, endDescending }

extension ChallengeSortExtension on ChallengeSort? {
  String? getSortString() {
    switch (this) {
      case ChallengeSort.userDivision:
        return 'userDivision';
      case ChallengeSort.endDescending:
        return '-endDate';
      case null:
        return null;
    }
  }
}

extension GrueneApiChallengeServiceExtension on GrueneApiChallengeService {
  Future<List<JoinedChallenge>> getAllMyChallenges({
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    ChallengeSort? sorting,
    bool? onlyCompleted,
    bool? onlyActiveCampaigns,
  }) async {
    var offset = 0;
    final pageSize = 200;
    var queryNextPage = true;
    List<JoinedChallenge> allPages = [];
    while (queryNextPage) {
      var currentPage = await getMyChallenges(
        challengeStatus: challengeStatus,
        campaignId: campaignId,
        sorting: sorting,
        onlyCompleted: onlyCompleted,
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

extension GrueneApiUserServiceExtension on GrueneApiUserService {
  Future<List<JoinedChallenge>> getAllMyChallenges({
    required String userId,
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    ChallengeSort? sorting,
    bool? onlyCompleted,
    bool? onlyActiveCampaigns,
  }) async {
    var offset = 0;
    final pageSize = 200;
    var queryNextPage = true;
    List<JoinedChallenge> allPages = [];
    while (queryNextPage) {
      var currentPage = await getUserChallenges(
        userId: userId,
        challengeStatus: challengeStatus,
        campaignId: campaignId,
        sorting: sorting,
        onlyCompleted: onlyCompleted,
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
