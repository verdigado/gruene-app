part of '../converters.dart';

extension NewTeamDetailsParsing on NewTeamDetails {
  CreateTeam asCreateTeam() {
    var memberships = [
      ...teamMembers!.map((m) => _asMembership(m, CreateTeamMembershipType.member)),
      _asMembership(selfJoin ? creatingUser : assignedTeamLead!, CreateTeamMembershipType.lead),
    ];
    return CreateTeam(
      divisionKey: assignedDivision!.divisionKey,
      name: name,
      description: description,
      memberships: memberships,
    );
  }

  CreateTeamMembership _asMembership(PublicProfile profile, CreateTeamMembershipType membershipType) {
    return CreateTeamMembership(userId: profile.userId, type: membershipType);
  }
}
