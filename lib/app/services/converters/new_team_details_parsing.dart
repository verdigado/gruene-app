part of '../converters.dart';

extension NewTeamDetailsParsing on NewTeamDetails {
  CreateTeam asCreateTeam() {
    return CreateTeam(
      divisionKey: assignedDivision!.divisionKey,
      name: name,
      description: description,
      memberships: getAllMemberships(),
    );
  }

  List<CreateTeamMembership> getAllMemberships() {
    var memberships = [
      ...teamMembers!.map((m) => _asMembership(m, TeamMembershipType.member)),
      _asMembership(selfJoin ? creatingUser : assignedTeamLead!, TeamMembershipType.lead),
    ];
    return memberships;
  }

  CreateTeamMembership _asMembership(PublicProfile profile, TeamMembershipType membershipType) {
    return CreateTeamMembership(userId: profile.userId, type: membershipType);
  }
}
