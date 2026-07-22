import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiChallengeService extends GrueneApiBaseService {
  Future<List<Challenge>> getChallenges({
    List<ChallengeActivityType>? activityTypes,
    num? offset,
    num? limit,
    List<ChallengeStatus>? challengeStatus,
  }) async => getFromApi(
    apiRequest: (api) =>
        api.v1CampaignsChallengesGet(activityType: activityTypes, offset: offset, limit: limit, state: challengeStatus),
    map: (result) => result.data,
  );

  Future<List<JoinedChallenge>> getMyChallenges({
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    JoinedChallengeSort? sorting,
    bool? onlyCompleted,
    bool? onlyActiveCampaigns,
  }) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesSelfGet(
      state: challengeStatus,
      campaignId: campaignId,
      sort: _getSort(sorting),
      onlyCompleted: onlyCompleted,
      onlyActiveCampaigns: onlyActiveCampaigns,
    ),
    map: (result) => result.data,
  );

  Future<ChallengeMembership> joinChallenge(String challengeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesChallengeIdJoinPost(challengeId: challengeId, body: null),
  );

  Future<void> leaveChallenge(String challengeId) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsChallengesChallengeIdLeavePost(challengeId: challengeId));

  Future<Challenge> getChallenge(String challengeId) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsChallengesChallengeIdGet(challengeId: challengeId));

  Future<List<ChallengeLeaderboardEntry>> getChallengeLeaderboard(String challengeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesChallengeIdLeaderboardGet(challengeId: challengeId, limit: 99),
    map: (result) => result.data,
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
