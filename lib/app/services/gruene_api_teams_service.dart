import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiTeamsService extends GrueneApiBaseService {
  Future<Team?> getOwnTeam() async => getFromApi<Team?, Team?>(apiRequest: (api) => api.v1CampaignsTeamsSelfGet());

  Future<Team> updateTeam({required String teamId, required String teamName, String? teamDescription}) async =>
      getFromApi<Team, Team>(
        apiRequest: (api) => api.v1CampaignsTeamsTeamIdPut(
          teamId: teamId,
          body: UpdateTeam(name: teamName, description: teamDescription),
        ),
      );

  Future<Team> createNewTeam(NewTeamDetails newTeamDetails) async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsTeamsPost(body: newTeamDetails.asCreateTeam()));

  Future<List<TeamInvitation>> getOpenInvitations() async =>
      getFromApi(apiRequest: (api) => api.v1CampaignsTeamsPendingInvitationsGet());

  Future<Team> acceptTeamMembership(String teamId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsTeamsTeamIdMembershipsStatusPut(
      teamId: teamId,
      body: UpdateTeamMembershipStatus(type: UpdateTeamMembershipStatusType.accept),
    ),
  );

  Future<Team> rejectTeamMembership(String teamId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsTeamsTeamIdMembershipsStatusPut(
      teamId: teamId,
      body: UpdateTeamMembershipStatus(type: UpdateTeamMembershipStatusType.reject),
    ),
  );

  Future<Team> addTeamMembership({required String teamId, required String userId}) => getFromApi(
    apiRequest: (api) => api.v1CampaignsTeamsTeamIdMembershipsPost(
      teamId: teamId,
      body: CreateTeamMembership(type: CreateTeamMembershipType.member, userId: userId),
    ),
  );

  Future<Team> removeTeamMembership({required String teamId, required String userId}) => getFromApi(
    apiRequest: (api) => api.v1CampaignsTeamsTeamIdMembershipsDelete(
      teamId: teamId,
      body: DeleteTeamMembership(userId: userId),
    ),
  );

  Future<Team> updateTeamMembership({
    required String teamId,
    required String userId,
    required TeamMembershipType membershipType,
  }) => getFromApi(
    apiRequest: (api) => api.v1CampaignsTeamsTeamIdMembershipsPut(
      teamId: teamId,
      body: UpdateTeamMembership(userId: userId, type: membershipType.asUpdateTeamMembershipType()),
    ),
  );
}
