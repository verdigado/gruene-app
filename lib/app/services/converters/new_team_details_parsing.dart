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
      ...teamMembers!.map((m) => _asMembership(m, CreateTeamMembershipType.member)),
      _asMembership(selfJoin ? creatingUser : assignedTeamLead!, CreateTeamMembershipType.lead),
    ];
    return memberships;
  }

  CreateTeamMembership _asMembership(PublicProfile profile, CreateTeamMembershipType membershipType) {
    return CreateTeamMembership(userId: profile.userId, type: membershipType);
  }
}
