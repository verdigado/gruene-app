import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiChallengeService extends GrueneApiBaseService {
  Future<List<Challenge>> getChallenges({
    List<ChallengeActivityType>? activityTypes,
    List<ChallengeStatus>? challengeStatus,
    JoinedChallengeSort? sorting,
    required num offset,
    required num limit,
  }) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesGet(
      activityType: activityTypes,
      offset: offset,
      limit: limit,
      state: challengeStatus,
      sort: _getSort(sorting),
    ),
    map: (result) => result.data,
  );

  Future<List<JoinedChallenge>> getAllMyChallenges({
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    JoinedChallengeSort? sorting,
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

  Future<FindJoinedChallengesResponse> getMyChallenges({
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    JoinedChallengeSort? sorting,
    bool? onlyCompleted,
    bool? onlyActiveCampaigns,
    required num offset,
    required num limit,
  }) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesSelfGet(
      state: challengeStatus,
      campaignId: campaignId,
      sort: _getSort(sorting),
      onlyCompleted: onlyCompleted,
      onlyActiveCampaigns: onlyActiveCampaigns,
      offset: offset,
      limit: limit,
    ),
  );

  Future<ChallengeMembership> joinChallenge(String challengeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesChallengeIdJoinPost(challengeId: challengeId, body: null),
  );

  Future<void> leaveChallenge(String challengeId) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsChallengesChallengeIdLeavePost(challengeId: challengeId));

  Future<Challenge> getChallenge(String challengeId) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsChallengesChallengeIdGet(challengeId: challengeId));

  Future<FindChallengeLeaderboardResponse> getChallengeLeaderboard(String challengeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesChallengeIdLeaderboardGet(challengeId: challengeId, limit: 99),
  );

  String? _getSort(JoinedChallengeSort? sorting) {
    if (sorting == null) return null;
    switch (sorting) {
      case JoinedChallengeSort.userDivision:
        return 'userDivision';
      case JoinedChallengeSort.endDescending:
        return '-endDate';
    }
  }
}

enum JoinedChallengeSort { userDivision, endDescending }
