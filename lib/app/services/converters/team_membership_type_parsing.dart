part of '../converters.dart';

extension TeamMembershipTypeParsing on TeamMembershipType {
  UpdateTeamMembershipType asUpdateTeamMembershipType() {
    switch (this) {
      case TeamMembershipType.lead:
        return UpdateTeamMembershipType.lead;
      case TeamMembershipType.member:
        return UpdateTeamMembershipType.member;
      case TeamMembershipType.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }
}
