import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/utils/globals.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiTeamsService extends GrueneApiBaseService {
  Future<Team?> getOwnTeam() async =>
      getFromApi<Team?, Team?>(apiRequest: (api) => api.v1CampaignsTeamsSelfGet(), map: id);

  Future<Team> updateTeam({required String teamId, required String teamName, String? teamDescription}) async =>
      getFromApi<Team, Team>(
        apiRequest: (api) => api.v1CampaignsTeamsTeamIdPut(
          teamId: teamId,
          body: UpdateTeam(name: teamName, description: teamDescription),
        ),
      );

  Future<Team> createNewTeam(NewTeamDetails newTeamDetails) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsTeamsPost(body: newTeamDetails.asCreateTeam()));
}
