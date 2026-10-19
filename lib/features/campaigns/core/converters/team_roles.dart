part of '../converters.dart';

extension TeamRoles on Team {
  bool isTeamLead(UserRbacStructure user) {
    return memberships
        .where((m) => m.type == TeamMembershipType.lead && m.status == TeamMembershipStatus.accepted)
        .any((m) => m.userId == user.userId);
  }
}
