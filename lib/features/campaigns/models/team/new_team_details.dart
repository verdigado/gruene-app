// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewTeamDetails {
  final String name;
  final String description;
  final bool selfJoin;
  final PublicProfile creatingUser;
  final Division? assignedDivision;
  final PublicProfile? assignedTeamLead;
  final List<PublicProfile>? teamMembers;

  NewTeamDetails({
    required this.name,
    required this.description,
    required this.selfJoin,
    required this.creatingUser,
    this.assignedDivision,
    this.assignedTeamLead,
    this.teamMembers,
  });

  NewTeamDetails copyWith({
    String? name,
    String? description,
    bool? selfJoin,
    PublicProfile? creatingUser,
    Division? assignedDivision,
    PublicProfile? assignedTeamLead,
    List<PublicProfile>? teamMembers,
  }) {
    return NewTeamDetails(
      name: name ?? this.name,
      description: description ?? this.description,
      selfJoin: selfJoin ?? this.selfJoin,
      creatingUser: creatingUser ?? this.creatingUser,
      assignedDivision: assignedDivision ?? this.assignedDivision,
      assignedTeamLead: assignedTeamLead ?? this.assignedTeamLead,
      teamMembers: teamMembers ?? this.teamMembers,
    );
  }
}
