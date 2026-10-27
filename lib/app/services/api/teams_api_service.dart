import 'package:gruene_app/app/models/campaigns/team/new_team_details.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamsApiService extends BaseApiService {
  Future<Team?> getOwnTeam() async => send<Team?, Team?>(request: (api) => api.v1CampaignsTeamsSelfGet());

  Future<TeamAssignmentResponse> getTeamAssignments({required String teamId}) =>
      send(request: (api) => api.v1CampaignsTeamsTeamIdAssignmentsGet(teamId: teamId));

  Future<Team> updateTeam({required String teamId, required String teamName, String? teamDescription}) async =>
      send<Team, Team>(
        request: (api) => api.v1CampaignsTeamsTeamIdPut(
          teamId: teamId,
          body: UpdateTeam(name: teamName, description: teamDescription),
        ),
      );

  Future<Team> createNewTeam(NewTeamDetails newTeamDetails) async =>
      send(request: (api) => api.v1CampaignsTeamsPost(body: newTeamDetails.toCreateTeam()));

  Future<List<TeamInvitation>> getOpenInvitations() async =>
      send(request: (api) => api.v1CampaignsTeamsPendingInvitationsGet());

  Future<Team> acceptTeamMembership(String teamId) async => send(
    request: (api) => api.v1CampaignsTeamsTeamIdMembershipStatusPut(
      teamId: teamId,
      body: UpdateTeamMembershipStatus(type: TeamMembershipStatusUpdateType.accept),
    ),
  );

  Future<Team> rejectTeamMembership(String teamId) async => send(
    request: (api) => api.v1CampaignsTeamsTeamIdMembershipStatusPut(
      teamId: teamId,
      body: UpdateTeamMembershipStatus(type: TeamMembershipStatusUpdateType.reject),
    ),
  );

  Future<Team> leaveTeam(String teamId) async => send(
    request: (api) => api.v1CampaignsTeamsTeamIdMembershipStatusPut(
      teamId: teamId,
      body: UpdateTeamMembershipStatus(type: TeamMembershipStatusUpdateType.resign),
    ),
  );

  Future<void> archiveTeam(String teamId) async =>
      send(request: (api) => api.v1CampaignsTeamsTeamIdActionArchivePut(teamId: teamId));

  Future<Team> addTeamMembership({required String teamId, required String userId}) => send(
    request: (api) => api.v1CampaignsTeamsTeamIdMembershipPost(
      teamId: teamId,
      body: CreateTeamMembership(type: TeamMembershipType.member, userId: userId),
    ),
  );

  Future<Team> removeTeamMembership({required String teamId, required String userId}) => send(
    request: (api) => api.v1CampaignsTeamsTeamIdMembershipDelete(
      teamId: teamId,
      body: DeleteTeamMembership(userId: userId),
    ),
  );

  Future<Team> updateTeamMembership({
    required String teamId,
    required String userId,
    required TeamMembershipType membershipType,
  }) => send(
    request: (api) => api.v1CampaignsTeamsTeamIdMembershipPut(
      teamId: teamId,
      body: UpdateTeamMembership(userId: userId, type: membershipType.toUpdateTeamMembershipType()),
    ),
  );

  Future<List<FindTeamsItem>> findTeams(List<String> divisionKeys) => send(
    request: (api) => api.v1CampaignsTeamsGet(divisionKeys: divisionKeys),
    map: (data) => data.data,
  );

  Future<TeamMembershipStatistics> getTeamMembershipStatistics({required String? campaignId}) =>
      send(request: (api) => api.v1CampaignsTeamsSelfMembershipStatisticsGet(campaignId: campaignId));

  Future<TeamStatistics> getTeamStatistics({required String? campaignId}) =>
      send(request: (api) => api.v1CampaignsTeamsStatisticsGet(campaignId: campaignId));
}
