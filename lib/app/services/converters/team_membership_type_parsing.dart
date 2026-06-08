part of '../converters.dart';

extension TeamMembershipTypeParsing on TeamMembershipType {
  TeamMembershipType asUpdateTeamMembershipType() {
    switch (this) {
      case TeamMembershipType.lead:
        return TeamMembershipType.lead;
      case TeamMembershipType.member:
        return TeamMembershipType.member;
      case TeamMembershipType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
