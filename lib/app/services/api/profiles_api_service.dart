import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfilesApiService extends BaseApiService {
  Future<Profile> getSelf() async => send(request: (api) => api.v1ProfilesSelfGet());

  Future<List<PublicProfile>> searchProfile(String searchText, {int? offset, int? limit}) async => send(
    request: (api) => api.v1ProfilesGet(search: searchText, offset: offset, limit: limit),
    map: (result) => result.data,
  );

  Future<PublicProfile> getProfile(String profileId) async =>
      send(request: (api) => api.v1ProfilesProfileIdGet(profileId: profileId));

  Future<FindCompletedChallengesResponse> getCompletedChallenges({
    required String profileId,
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    ChallengeSort? sorting,
    bool? onlyActiveCampaigns,
    required num offset,
    required num limit,
  }) async => send(
    request: (api) => api.v1ProfilesProfileIdCompletedChallengesGet(
      profileId: profileId,
      state: challengeStatus,
      campaignId: campaignId,
      sort: sorting.getSortString(),
      onlyActiveCampaigns: onlyActiveCampaigns,
      offset: offset,
      limit: limit,
    ),
  );
}
