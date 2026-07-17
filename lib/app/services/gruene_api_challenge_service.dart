import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
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

  Future<List<JoinedChallenge>> getMyChallenges() async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesSelfGet(state: CampaignConstants.currentlyOngoingChallengeFilter),
    map: (result) => result.data,
  );

  Future<ChallengeMembership> joinChallenge(String challengeId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsChallengesChallengeIdJoinPost(challengeId: challengeId, body: null),
  );

  Future<ChallengeMembership> leaveChallenge(String challengeId) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsChallengesChallengeIdLeavePost(challengeId: challengeId));
}
