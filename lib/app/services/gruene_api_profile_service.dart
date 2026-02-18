import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiProfileService extends GrueneApiBaseService {
  Future<Profile> getSelf() async => getFromApi(apiRequest: (api) => api.v1ProfilesSelfGet());

  Future<List<PublicProfile>> searchProfile(String searchText, {int? offset, int? pageSize}) async => getFromApi(
    apiRequest: (api) => api.v1ProfilesGet(search: searchText, offset: offset, limit: pageSize),
    map: (result) => result.data,
  );

  Future<PublicProfile> getProfile(String profileId) async =>
      getFromApi(apiRequest: (api) => api.v1ProfilesProfileIdGet(profileId: profileId));

  Future<Profile> getOwnProfile() async => getFromApi(apiRequest: (api) => api.v1ProfilesSelfGet());

  Future<Profile> updateProfile(Profile profile) async => getFromApi(
    apiRequest: (api) =>
        api.v1ProfilesProfileIdPut(profileId: profile.id, body: UpdateProfile.fromJson(profile.toJson())),
  );
}
