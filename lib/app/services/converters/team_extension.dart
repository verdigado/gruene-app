part of '../converters.dart';

extension TeamExtension on Team {
  bool isTeamLead(UserRbacStructure user) {
    return memberships
        .where((m) => m.type == TeamMembershipType.lead && m.status == TeamMembershipStatus.accepted)
        .any((m) => m.userId == user.userId);
  }

  TeamInfo asRouteTeam() {
    return TeamInfo(id: id, divisionKey: division?.divisionKey ?? '', name: name);
  }
}

extension FindTeamsItemExtension on FindTeamsItem {
  TeamInfo asRouteTeam() {
    return TeamInfo(id: id, divisionKey: '', name: name);
  }
}
