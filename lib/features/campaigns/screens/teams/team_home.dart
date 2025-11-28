import 'package:flutter/material.dart';
import 'package:gruene_app/app/auth/repository/user_info.dart';
import 'package:gruene_app/features/campaigns/screens/teams/team_profile.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamHome extends StatefulWidget {
  final UserInfo currentUser;

  const TeamHome({super.key, required this.currentUser});

  @override
  State<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends State<TeamHome> {
  bool _loading = true;

  late Team? _currentTeam;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    // TODO remove mock data when getOwnTeam is working
    // var teamsService = GetIt.I<GrueneApiTeamsService>();
    // var team = await teamsService.getOwnTeam();
    var team = Team(
      id: '1',
      userId: '123',
      divisionKey: '5936',
      createdAt: DateTime.now(),
      name: 'Team Oktopus',
      description: '''Bestes HTWK Team jenseits der Panke
Chat: https://signal.group/#123456''',
      status: TeamStatus.active,
      memberships: [
        TeamMembership(
          id: 'id',
          userId: widget.currentUser.uidnumber,
          createdAt: DateTime.now(),
          start: DateTime.now(),
          end: DateTime.now(),
          type: TeamMembershipType.lead,
          status: TeamMembershipStatus.accepted,
        ),
      ],
    );

    setState(() {
      _loading = false;
      _currentTeam = team;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(padding: EdgeInsets.fromLTRB(24, 24, 24, 6), child: CircularProgressIndicator());
    }
    return Column(
      children: [
        _currentTeam != null
            ? TeamProfile(currentTeam: _currentTeam!, currentUser: widget.currentUser)
            : SizedBox.shrink(),
      ],
    );
  }
}
