import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiProfileService extends GrueneApiBaseService {
  Future<Profile> getSelf() async => getFromApi(apiRequest: (api) => api.v1ProfilesSelfGet(), map: (result) => result);

  Future<List<PublicProfile>> searchProfile(String searchText) async => getFromApi(
    apiRequest: (api) => api.v1ProfilesGet(search: searchText),
    map: (result) => result.data,
  );
}
