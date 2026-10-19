part of '../converters.dart';

extension TeamMembershipTypeMapping on TeamMembershipType {
  TeamMembershipType toUpdateTeamMembershipType() {
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
