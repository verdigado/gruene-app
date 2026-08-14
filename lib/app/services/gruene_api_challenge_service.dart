import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiChallengeService extends GrueneApiBaseService {
  Future<List<Challenge>> getChallenges({
    List<ChallengeActivityType>? activityTypes,
    List<ChallengeStatus>? challengeStatus,
    ChallengeSort? sorting,
    required num offset,
    required num limit,
  }) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesGet(
      activityType: activityTypes,
      offset: offset,
      limit: limit,
      state: challengeStatus,
      sort: sorting.getSortString(),
    ),
    map: (result) => result.data,
  );

  Future<FindJoinedChallengesResponse> getMyChallenges({
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    ChallengeSort? sorting,
    bool? onlyCompleted,
    bool? onlyActiveCampaigns,
    required num offset,
    required num limit,
  }) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesSelfGet(
      state: challengeStatus,
      campaignId: campaignId,
      sort: sorting.getSortString(),
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
}
