import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/utils/globals.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiProfileService extends GrueneApiBaseService {
  Future<Profile> getSelf() async => getFromApi(apiRequest: (api) => api.v1ProfilesSelfGet(), map: id);

  Future<List<PublicProfile>> searchProfile(String searchText) async => getFromApi(
    apiRequest: (api) => api.v1ProfilesGet(search: searchText),
    map: (result) => result.data,
  );

  Future<PublicProfile> getProfile(String profileId) async =>
      getFromApi(apiRequest: (api) => api.v1ProfilesProfileIdGet(profileId: profileId));

  Future<Profile> updateProfile(Profile profile) async => getFromApi(
    apiRequest: (api) =>
        api.v1ProfilesProfileIdPut(profileId: profile.id, body: UpdateProfile.fromJson(profile.toJson())),
  );
}
