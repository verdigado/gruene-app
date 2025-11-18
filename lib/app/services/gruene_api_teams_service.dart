import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiTeamsService extends GrueneApiBaseService {
  Future<Object> getOwnTeam() async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsTeamsSelfGet(), map: (result) => result);

  Future<Object> createNewTeam(CreateTeam createTeam) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsTeamsPost(body: createTeam),
    map: (result) => result,
  );
}
