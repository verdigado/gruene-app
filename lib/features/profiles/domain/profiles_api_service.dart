import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

Future<List<PublicProfile>> fetchProfiles({
  String? query,
  Division? division,
  List<ProfileTag>? tags = const [],
}) async => getFromApi(
  request: (api) => api.v1ProfilesGet(
    search: query,
    division: division?.implicitMembersDivisionKey,
    tags: tags?.map((tag) => tag.externalId!).toList(),
    limit: 1000,
  ),
  map: (data) => data.data,
);

Future<PublicProfile> fetchProfile(String profileId) async => getFromApi(
  request: (api) => api.v1ProfilesProfileIdGet(profileId: profileId),
  map: (data) => data,
);

Future<Profile> fetchOwnProfile() async => getFromApi(request: (api) => api.v1ProfilesSelfGet(), map: (data) => data);

Future<Profile> updateProfile(Profile profile) async => getFromApi(
  request: (api) => api.v1ProfilesProfileIdPut(profileId: profile.id, body: profile.updateProfile),
);

Future<Profile> updateProfileImage({required String profileId, required MultipartFile profileImage}) async =>
    getFromApi(
      request: (api) => api.v1ProfilesProfileIdImagePut(profileId: profileId, profileImage: profileImage),
      map: (data) => data,
    );

Future<Profile> deleteProfileImage({required String profileId}) async => getFromApi(
  request: (api) => api.v1ProfilesProfileIdImageDelete(profileId: profileId),
  map: (data) => data,
);

Future<List<ProfileTag>> fetchProfileTags() async =>
    getFromApi(request: (api) => api.v1ProfileTagsGet(limit: 1000), map: (data) => data.data);
