import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

class ProfileApiService extends BaseApiService {
  Future<Profile> getOwnProfile() async => send(request: (api) => api.v1ProfilesSelfGet());

  Future<PublicProfile> getProfile(String profileId) async =>
      send(request: (api) => api.v1ProfilesProfileIdGet(profileId: profileId));

  Future<List<PublicProfile>> getProfiles({
    String? search,
    Division? division,
    List<ProfileTag>? tags = const [],
    int? limit = 100,
    int? offset,
  }) async => send(
    request: (api) => api.v1ProfilesGet(
      search: search,
      division: division?.implicitMembersDivisionKey,
      tags: tags?.map((tag) => tag.externalId!).toList(),
      limit: limit,
      offset: offset,
    ),
    map: (data) => data.data,
  );

  Future<Profile> updateProfile(Profile profile) async => send(
    request: (api) => api.v1ProfilesProfileIdPut(profileId: profile.id, body: profile.updateProfile),
  );

  Future<Profile> updateProfileImage({required String profileId, required MultipartFile profileImage}) async => send(
    request: (api) => api.v1ProfilesProfileIdImagePut(profileId: profileId, profileImage: profileImage),
  );

  Future<Profile> deleteProfileImage({required String profileId}) async =>
      send(request: (api) => api.v1ProfilesProfileIdImageDelete(profileId: profileId));

  Future<List<ProfileTag>> getProfileTags() async =>
      send(request: (api) => api.v1ProfileTagsGet(limit: 1000), map: (data) => data.data);

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
