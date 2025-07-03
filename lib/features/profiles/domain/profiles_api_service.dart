import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

Future<Profile> fetchOwnProfile() async => getFromApi(request: (api) => api.v1ProfilesSelfGet(), map: (data) => data);

Future<Profile> updateProfileImage({required String profileId, required MultipartFile profileImage}) async =>
    getFromApi(
      request: (api) => api.v1ProfilesProfileIdImagePut(profileId: profileId, profileImage: profileImage),
      map: (data) => data,
    );

Future<Profile> deleteProfileImage({required String profileId}) async => getFromApi(
  request: (api) => api.v1ProfilesProfileIdImageDelete(profileId: profileId),
  map: (data) => data,
);
